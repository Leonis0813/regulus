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
BATCH_SIZE = int(args[4])
PERIODS = ['25', '75', '200']
Settings = yaml.load(open(WORKDIR + '/settings.yml', 'r+'))

def open(candle_stick):
  return candle_stick['open']

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

raw_data = pd.DataFrame()
normalized_data = pd.DataFrame()
length = np.inf

cursor = connection.cursor(dictionary=True)
cursor.execute(
  'SELECT open FROM candle_sticks ' \
  'WHERE `from` BETWEEN "' + FROM + '" AND "' + TO + '" AND ' \
    'pair = "' + TARGET_PAIR + '" AND ' \
    'time_frame = "D1" AND ' \
  'ORDER BY `from`'
)
records = cursor.fetchall()
opens = (record['open'] for record in records)
raw_data['open'] = opens
normalized_data['open'] = min_max(opens)

vfunc = np.vectorize(value)
for period in PERIODS:
  cursor.execute(
    'SELECT value FROM moving_averages ' \
    'WHERE `time` BETWEEN "' + FROM + '" AND "' + TO + '" AND ' \
      'pair = "' + TARGET_PAIR + '" AND ' \
      'time_frame = "D1" AND ' \
      'period = ' + period + ' ' \
    'ORDER BY `time`'
  )
  values = vfunc(cursor.fetchall())
  normalized_values = min_max(values)
  length = len(normalized_values) if length > len(normalized_values) else length
  raw_data['ma_' + period] = values
  normalized_data['ma_' + period] = normalized_values

raw_data.to_csv(WORKDIR + '/tmp/raw_data.csv', index=False)
normalized_data.to_csv(WORKDIR + '/tmp/normalized_data.csv', index=False)

training_data = pd.DataFrame()

for index in range(0, 20):
  key = 'open_' + str(index)
  training_data[key] = normalized_data['open'][index:(length + index - 20 - 1)].values

for period in PERIODS:
  for index in range(0, 20):
    key = 'ma_' + period
    new_key = key + '_' + str(index)
    training_data[new_key] = normalized_data[key][index:(index + index - 20 - 1)].values

latests = normalized_data['open'][19:38].values
futures = normalized_data['open'][20:39].values
labels = []
for i in range(0, 20):
  labels += [1] if (latests[i] < futures[i]) else [0]

training_data['label'] = labels
training_data.to_csv(WORKDIR + '/tmp/training_data.csv', index=False)

x = tf.placeholder(tf.float32, [None, 80])

w_1 = tf.Variable(tf.truncated_normal([80, 64], stddev=0.1), name="w1")
b_1 = tf.Variable(tf.zeros([64]), name="b1")
h_1 = tf.nn.relu(tf.matmul(x, w_1) + b_1)

w_2 = tf.Variable(tf.truncated_normal([64, 32], stddev=0.1), name="w2")
b_2 = tf.Variable(tf.zeros([32]), name="b2")
h_2 = tf.nn.relu(tf.matmul(h_1, w_2) + b_2)

w_3 = tf.Variable(tf.truncated_normal([32, 16], stddev=0.1), name="w3")
b_3 = tf.Variable(tf.zeros([16]), name="b3")
h_3 = tf.nn.relu(tf.matmul(h_2, w_3) + b_3)

w_4 = tf.Variable(tf.truncated_normal([16, 8], stddev=0.1), name="w4")
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
  with tf.name_scope('summary'):
    tf.summary.scalar('loss', loss)
    merged = tf.summary.merge_all()
    writer = tf.summary.FileWriter(WORKDIR + '/tmp/logs', sess.graph)

  sess.run(init)

  for i in range(10000):
    batch_data = training_data.sample(n=BATCH_SIZE)
    labels = []
    for label in batch_data['label'].values:
      labels += [[label]]
    inputs = batch_data.drop(['label'], axis=1).values
    sess.run(train_step, feed_dict={x:inputs, y:labels})

  saver.save(sess, WORKDIR + '/tmp/model.ckpt')
