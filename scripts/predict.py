import mysql.connector as mysql
import numpy as np
import tensorflow as tf
import os
import sys
import yaml

args = sys.argv
PERIODS = ['25', '75', '200']
PAIRS = ['USDJPY', 'EURJPY', 'EURUSD', 'AUDJPY', 'GBPJPY', 'CADJPY', 'CHFJPY', 'NZDJPY']
Settings = yaml.load(open(os.path.dirname(os.path.abspath(args[0])) + '/settings.yml', 'r+'))
result_file = open(os.path.dirname(os.path.abspath(args[0])) + '/tmp/result.yml', 'w')

def value(record):
  return record['value']

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
test_data = np.empty((0, 720), float)
input = np.empty(0, float)

for pair in PAIRS:
  for period in PERIODS:
    cursor.execute(
      'SELECT value FROM moving_averages ' \
      'WHERE pair = "' + pair + '" AND ' \
        'time_frame = "H1" AND ' \
        'period = ' + period + ' ' \
      'ORDER BY `time` DESC ' \
      'LIMIT 30'
    )
    values = vfunc(cursor.fetchall())
    values = values[::-1]
    values = min_max(values)
    input = np.append(input, np.array(values))

test_data = np.append(test_data, np.array([input]), axis=0)

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

saver = tf.train.Saver()

with tf.Session() as sess:
  saver.restore(sess, os.path.dirname(os.path.abspath(args[0])) + '/tmp/model.ckpt')
  result = sess.run(out, feed_dict={x:test_data})

  cursor.execute(
    'SELECT `time` FROM moving_averages ' \
    'WHERE pair = "USDJPY" AND ' \
      'time_frame = "H1" AND ' \
      'period = 25 ' \
    'ORDER BY `time` DESC ' \
    'LIMIT 30'
  )
  records = cursor.fetchall()
  result_file.write("from: " + records[-1]['time'].strftime('%Y-%m-%d %H:%M:%S') + "\n")
  result_file.write("to: " + records[0]['time'].strftime('%Y-%m-%d %H:%M:%S') + "\n")

  prediction = result[0][0]
  if prediction > 0.5:
    result_file.write("result: up\n")
  else:
    result_file.write("result: down\n")
  result_file.close()
