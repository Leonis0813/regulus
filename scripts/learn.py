import mysql.connector as mysql
import numpy as np
import os
import pandas as pd
import sys
import tensorflow as tf
import yaml

args = sys.argv
WORKDIR = os.path.dirname(os.path.abspath(args[0]))
FROM = args[1]
TO = args[2]
TARGET_PAIR = args[3]
BATCH_SIZE = args[4]
PERIODS = ['25', '75', '200']
PAIRS = ['USDJPY', 'EURJPY', 'EURUSD', 'AUDJPY', 'GBPJPY', 'CADJPY', 'CHFJPY', 'NZDJPY']
Settings = yaml.load(open(WORKDIR + '/settings.yml', 'r+'))

def value(moving_average):
  return moving_average['value']

def min_max(x):
  min = x.min(axis=0, keepdims=True)
  max = x.max(axis=0, keepdims=True)
  return 2.0 * ((x - min) / (max - min) - 0.5)

connection = mysql.connect(
  host = Settings['mysql']['host'],
  user = Settings['mysql']['user'],
  password = Settings['mysql']['password'],
  database = Settings['mysql']['database'],
)

cursor = connection.cursor(dictionary=True)
vfunc = np.vectorize(value)
moving_average = pd.DataFrame()
length = np.inf

for pair in PAIRS:
  for period in PERIODS:
    cursor.execute(
      'SELECT value FROM moving_averages ' \
      'WHERE `time` BETWEEN "' + FROM + '" AND "' + TO + '" AND ' \
        'pair = "' + pair + '" AND ' \
        'time_frame = "H1" AND ' \
        'period = ' + period + ' ' \
      'ORDER BY `time`'
    )
    values = vfunc(cursor.fetchall())
    values = min_max(values)
    length = len(values) if length > len(values) else length
    moving_average[pair + '_' + period] = values

training_data = pd.DataFrame()

for pair in PAIRS:
  for period in PERIODS:
    for index in range(0, 30):
      key = pair + '_' + period
      new_key = key + '_' + str(index)
      training_data[new_key] = moving_average[key][index:(length - 54 + index)].values

labels = []
latests = []
futures = []
target_moving_average = moving_average[TARGET_PAIR + '_25']

for i in range(0, length - 54):
  latests += target_moving_average[i + 30 - 1]
  futures += target_moving_average[i + 54 - 1]

for i in range(0, length - 54):
  labels += [i] if (latests[i] < futures[i]) else [0]

training_data['latests'] = latests
training_data['futures'] = futures
training_data['label'] = labels
training_data.to_csv(WORKDIR + '/tmp/training_data.csv', index=False)

x = tf.placeholder(tf.float32, [None, 720])

w_1 = tf.Variable(tf.truncated_normal([720, 512], stddev=0.1), name="w1")
b_1 = tf.Variable(tf.zeros([512]), name="b1")
h_1 = tf.nn.relu(tf.matmul(x, w_1) + b_1)

w_2 = tf.Variable(tf.truncated_normal([512, 128], stddev=0.1), name="w2")
b_2 = tf.Variable(tf.zeros([128]), name="b2")
h_2 = tf.nn.relu(tf.matmul(h_1, w_2) + b_2)

w_3 = tf.Variable(tf.truncated_normal([128, 32], stddev=0.1), name="w3")
b_3 = tf.Variable(tf.zeros([32]), name="b3")
h_3 = tf.nn.relu(tf.matmul(h_2, w_3) + b_3)

w_4 = tf.Variable(tf.truncated_normal([32, 8], stddev=0.1), name="w4")
b_4 = tf.Variable(tf.zeros([8]), name="b4")
h_4 = tf.nn.relu(tf.matmul(h_3, w_4) + b_4)

w_5 = tf.Variable(tf.truncated_normal([8, 1], stddev=0.1), name="w5")
b_5 = tf.Variable(tf.zeros([1]), name="b5")
out = tf.nn.softmax(tf.matmul(h_4, w_5) + b_5)

y = tf.placeholder(tf.float32, [None, 1])
loss = tf.reduce_mean(tf.square(y - out))
train_step = tf.train.GradientDescentOptimizer(0.5).minimize(loss)

init = tf.global_variables_initializer()

saver = tf.train.Saver()

with tf.Session() as sess:
  sess.run(init)

  for i in range(10000):
    step = i + 1
    batch_data = training_data.sample(n=int(BATCH_SIZE))
    labels = []
    for l in batch_data['label'].values:
      labels += [[l]]
    sess.run(train_step, feed_dict={x:batch_data.drop('label', axis=1).values, y:labels})

  saver.save(sess, os.path.dirname(os.path.abspath(args[0])) + '/tmp/model.ckpt')
