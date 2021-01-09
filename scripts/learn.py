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
mysql = yaml.load(open(WORKDIR + '../config/zosma/database.yml', 'r+'))

connection = mysql.connect(
  host = mysql[param['env']]['host'],
  user = mysql[param['env']]['username'],
  password = mysql[param['env']]['password'],
  database = mysql[param['env']]['database'],
)

raw_data = pd.DataFrame()

cursor = connection.cursor(dictionary=True)
cursor.execute(
  open(WORKDIR + '/training_data.sql').read()
  .replace("${FROM}", param['from'])
  .replace("${TO}", param['to'])
  .replace("${PAIR}", param['pair'])
)
records = cursor.fetchall()

for record in records:
  raw_data = raw_data.append(record, ignore_index=True)

normalized_data = pd.DataFrame()
normalized_data['time'] = raw_data['time']
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
for column in list(set(raw_data.columns) - set(['time'])):
  normalized_data[column] = 2.0 * (raw_data[column] - min) / (max - min) - 1.0

raw_data.to_csv(WORKDIR + '/tmp/raw_data.csv', index=False)
normalized_data.to_csv(WORKDIR + '/tmp/normalized_data.csv', index=False)

training_data = pd.DataFrame()

for row_index in range(0, len(normalized_data) - 21):
  row = {}

  for date_index in range(0, 20):
    row.update({
      'open_' + str(date_index): normalized_data['open'][row_index + date_index],
      'ma25_' + str(date_index): normalized_data['ma25'][row_index + date_index],
      'ma75_' + str(date_index): normalized_data['ma75'][row_index + date_index],
      'ma200_' + str(date_index): normalized_data['ma200'][row_index + date_index],
    })

  row['label'] = 1 if row['open_19'] < normalized_data['open'][row_index + 21] else 0
  training_data = training_data.append(row, ignore_index=True)

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

w_5 = tf.Variable(tf.truncated_normal([8, 2], stddev=0.1), name="w5")
b_5 = tf.Variable(tf.zeros([2]), name="b5")
out = tf.nn.softmax(tf.matmul(h_4, w_5) + b_5)

y = tf.placeholder(tf.float32, [None, 2])
loss = tf.reduce_mean(tf.square(y - out))
train_step = tf.train.GradientDescentOptimizer(0.5).minimize(loss)

init = tf.global_variables_initializer()

saver = tf.train.Saver()

with tf.Session() as sess:
  with tf.name_scope('summary'):
    tf.summary.histogram('w_1', w_1)
    tf.summary.histogram('b_1', b_1)
    tf.summary.histogram('w_2', w_2)
    tf.summary.histogram('b_2', b_2)
    tf.summary.histogram('w_3', w_3)
    tf.summary.histogram('b_3', b_3)
    tf.summary.histogram('w_4', w_4)
    tf.summary.histogram('b_4', b_4)
    tf.summary.histogram('w_5', w_5)
    tf.summary.histogram('b_5', b_5)
    tf.summary.histogram('out', out)
    tf.summary.scalar('loss', loss)
    merged = tf.summary.merge_all()
    writer = tf.summary.FileWriter(WORKDIR + '/tmp/logs', sess.graph)

  sess.run(init)

  for i in range(10000):
    batch_data = training_data.sample(n=param['batch_size'])
    labels = []
    for label in batch_data['label'].values:
      labels += [[1.0, 0.0]] if label == 1.0 else [[0.0, 1.0]]
    inputs = batch_data.drop(['label'], axis=1).values
    _, summary = sess.run([train_step, merged], feed_dict={x:inputs, y:labels})
    if i % 100 == 0:
      writer.add_summary(summary, i)

  saver.save(sess, WORKDIR + '/tmp/model.ckpt')
