import mysql.connector as mysql
import numpy as np
import tensorflow as tf
import os
import sys
import yaml

args = sys.argv
FROM = args[1]
TO = args[2]
BATCH_SIZE = args[3]
PERIODS = ['25', '75', '200']
PAIRS = ['USDJPY', 'EURJPY', 'EURUSD', 'AUDJPY', 'GBPJPY', 'CADJPY', 'CHFJPY', 'NZDJPY']
Settings = yaml.load(open(os.path.dirname(os.path.abspath(args[0])) + '/settings.yml', 'r+'))

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
moving_average = {}
length = np.inf

for pair in PAIRS:
  moving_average[pair] = {}
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
    moving_average[pair][period] = values

inputs = np.empty((0, 720), float)
labels = np.empty((0, 1), int)

for i in range(0, length - 54):
  input = np.empty(0)
  for pair in PAIRS:
    for period in PERIODS:
      input = np.append(input, np.array(moving_average[pair][period][i:i+30]))

  inputs = np.append(inputs, np.array([input]), axis=0)

  usdjpy_25 = moving_average['USDJPY']['25']
  if (usdjpy_25[i + 30] + 0.01 < usdjpy_25[i + 54]):
    labels = np.append(labels, np.array([[1]]), axis=0)
  else:
    labels = np.append(labels, np.array([[0]]), axis=0)

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

    indices = np.random.randint(0, len(inputs), int(BATCH_SIZE), int)
    batch_data = inputs[indices]
    batch_label = labels[indices]
    sess.run(train_step, feed_dict={x:batch_data, y:batch_label})

  saver.save(sess, "/opt/scripts/tmp/model.ckpt")
