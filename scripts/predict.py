import mysql.connector as mysql
import numpy as np
import os
import pandas as pd
import sys
import tensorflow as tf
import yaml

args = sys.argv
WORKDIR = os.path.dirname(os.path.abspath(args[0]))
param = yaml.load(open(WORKDIR + '/tmp/parameter.yml', 'r+'))
database = yaml.load(open(WORKDIR + '/../config/zosma/database.yml', 'r+'))
result_file = open(WORKDIR + '/tmp/result.yml', 'w')

connection = mysql.connect(
  host = database[param['env']]['host'],
  user = database[param['env']]['username'],
  password = database[param['env']]['password'],
  database = database[param['env']]['database'],
)

sql = open(WORKDIR + '/test_data.sql').read()
.replace("${PAIR}", param['pair']))
.replace("${TO}", param['to'])

cursor = connection.cursor(dictionary=True)
cursor.execute(sql)
records = cursor.fetchall()

raw_data = pd.DataFrame()
for record in records:
  raw_data = raw_data.append(record, ignore_index=True)

normalized_data = pd.DataFrame()
for column in list(set(raw_data.columns) - set(['time'])):
  normalized_data[column] = 2.0 * (raw_data[column] - param['min']) / (param['max'] - param['min']) - 1.0

test_data = []
for column in ['ma25', 'ma75', 'ma200', 'open']:
  for index in range(0, 20):
    test_data.append(normalized_data[column][index])

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

w_5 = tf.Variable(tf.truncated_normal([8, 2], stddev=0.1), name="w5")
b_5 = tf.Variable(tf.zeros([2]), name="b5")
out = tf.nn.softmax(tf.matmul(h_4, w_5) + b_5)

saver = tf.train.Saver()

with tf.Session() as sess:
  saver.restore(sess, os.path.dirname(os.path.abspath(args[0])) + '/tmp/model.ckpt')
  result = sess.run(out, feed_dict={x:[test_data]})

  up, down = result[0]
  result_file.write("from: " + records[-1]['time'].strftime('%Y-%m-%d %H:%M:%S') + "\n")
  result_file.write("to: " + records[0]['time'].strftime('%Y-%m-%d %H:%M:%S') + "\n")
  result_file.write("up: " + up + "\n")
  result_file.write("down: " + down + "\n")
  result_file.close()
