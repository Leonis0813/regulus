import mysql.connector as mysql
import numpy as np
import tensorflow as tf
import os
import sys
import yaml

args = sys.argv
WORKDIR = os.path.dirname(os.path.abspath(args[0]))
TARGET_PAIR = args[1]
Settings = yaml.load(open(WORKDIR + '/settings.yml', 'r+'))
result_file = open(WORKDIR + '/tmp/result.yml', 'w')

connection = mysql.connect(
  host = Settings['mysql']['host'],
  user = Settings['mysql']['user'],
  password = Settings['mysql']['password'],
  database = Settings['mysql']['database'],
)

cursor = connection.cursor(dictionary=True)
cursor.execute(open(WORKDIR + '/test_data.sql').read().replace("${PAIR}", TARGET_PAIR))
records = cursor.fetchall()

raw_data = pd.DataFrame()
for record in records:
  raw_data = raw_data.append(record, ignore_index=True)

normalized_data = pd.DataFrame()
max = max(
  raw_data['open'].max(),
  raw_data['ma25'].max(),
  raw_data['ma75'].max(),
  raw_data['ma200'].max()
)
min = min(
  raw_data['open'].min(),
  raw_data['ma25'].min(),
  raw_data['ma75'].min(),
  raw_data['ma200'].min()
)
for column in raw_data.columns:
  normalized_data[column] = 2.0 * (raw_data[column] - min) / (max - min) - 1.0

raw_data.to_csv(WORKDIR + '/tmp/raw_data.csv', index=False)
normalized_data.to_csv(WORKDIR + '/tmp/normalized_data.csv', index=False)

test_data = normalized_data.to_numpy.ravel()

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

  result_file.write("from: " + records[-1]['time'].strftime('%Y-%m-%d %H:%M:%S') + "\n")
  result_file.write("to: " + records[0]['time'].strftime('%Y-%m-%d %H:%M:%S') + "\n")

  prediction = result[0][0]
  if prediction > 0.5:
    result_file.write("result: up\n")
  else:
    result_file.write("result: down\n")
  result_file.close()
