import mysql.connector as mysql
import numpy as np
import tensorflow as tf
import os
import sys
import yaml

args = sys.argv
SETTINGS = yaml.load(open(os.path.dirname(os.path.abspath(args[0])) + '/settings.yml', 'r+'))
result_file = open("/opt/scripts/tmp/result.yml", 'w')

connection = mysql.connect(
  host = SETTINGS['mysql']['host'],
  user = SETTINGS['mysql']['user'],
  password = SETTINGS['mysql']['password'],
  database = SETTINGS['mysql']['database'],
)

cursor = connection.cursor(dictionary=True)
cursor.execute(
  'SELECT `to`, open FROM candle_sticks '\
  'WHERE pair = "USDJPY" AND '\
    'WEEKDAY(`to`) BETWEEN 0 AND 4 '\
  'ORDER BY `to` DESC '\
  'LIMIT 300'
)

def open(records):
  return records['open']

def to(records):
  return records['to']

def min_max(x):
  min = x.min(axis=0, keepdims=True)
  max = x.max(axis=0, keepdims=True)
  result = 2.0 * ((x - min) / (max - min) - 0.5)
  return result

vfunc_open = np.vectorize(open)
vfunc_time = np.vectorize(to)
records = cursor.fetchall()
candle_sticks = vfunc_open(records)
time = vfunc_time(records)

candle_sticks = min_max(candle_sticks)
test_data = np.empty((0, 300), float)
test_data = np.append(data, np.array([candle_sticks[0:300]]), axis=0)

x = tf.placeholder(tf.float32, [None, 300])

w_1 = tf.Variable(tf.truncated_normal([300, 100], stddev=0.1), name="w1")
b_1 = tf.Variable(tf.zeros([100]), name="b1")
h_1 = tf.nn.relu(tf.matmul(x, w_1) + b_1)

w_2 = tf.Variable(tf.truncated_normal([100, 3], stddev=0.1), name="w2")
b_2 = tf.Variable(tf.zeros([3]), name="b2")
out = tf.nn.softmax(tf.matmul(h_1, w_2) + b_2)

saver = tf.train.Saver()

with tf.Session() as sess:
  saver.restore(sess, "/opt/scripts/tmp/model.ckpt")
  result = sess.run(out, feed_dict={x:test_data})

  result_file.write("from: " + time[-1].strftime('%Y-%m-%d %H:%M:%S') + "\n")
  result_file.write("to: " + time[0].strftime('%Y-%m-%d %H:%M:%S') + "\n")

  prediction = result[0].argmax()
  if prediction == 0:
    result_file.write("result: up\n")
  elif prediction == 1:
    result_file.write("result: range\n")
  else:
    result_file.write("result: down\n")
  result_file.close()
