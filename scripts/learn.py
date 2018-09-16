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
SETTINGS = yaml.load(open(os.path.dirname(os.path.abspath(sys.argv[0])) + '/settings.yml', 'r+'))

connection = mysql.connect(
  host = SETTINGS['mysql']['host'],
  user = SETTINGS['mysql']['user'],
  password = SETTINGS['mysql']['password'],
  database = SETTINGS['mysql']['database'],
)

cursor = connection.cursor(dictionary=True)
cursor.execute(
  'SELECT bid FROM rates '\
  'WHERE pair = "USDJPY" AND '\
    'WEEKDAY(time) BETWEEN 0 AND 4 AND '\
    'time BETWEEN "' + FROM + '" "' + TO + '" '\
  'ORDER BY time'
)

def bid(rate):
  return rate['bid']

def min_max(x):
  min = x.min(axis=0, keepdims=True)
  max = x.max(axis=0, keepdims=True)
  result = 2.0 * ((x - min) / (max - min) - 0.5)
  return result

vfunc = np.vectorize(bid)
rates = vfunc(cursor.fetchall())
rates = min_max(rates)

data = np.empty((0, 300), float)
label = np.empty((0, 3), int)

for i in range(0, len(rates) - 450, 150):
  if (rates[i+300] + 0.01) < rates[i+450]:
    label = np.append(label, np.array([[1,0,0]]), axis=0)
  elif (rates[i+300] - 0.01 ) > rates[i+450]:
    label = np.append(label, np.array([[0,1,0]]), axis=0)
  else:
    label = np.append(label, np.array([[0,0,1]]), axis=0)

  data = np.append(data, np.array([rates[i:i+300]]), axis=0)

x = tf.placeholder(tf.float32, [None, 300])

w_1 = tf.Variable(tf.truncated_normal([300, 100], stddev=0.1), name="w1")
b_1 = tf.Variable(tf.zeros([100]), name="b1")
h_1 = tf.nn.relu(tf.matmul(x, w_1) + b_1)

w_2 = tf.Variable(tf.truncated_normal([100, 3], stddev=0.1), name="w2")
b_2 = tf.Variable(tf.zeros([3]), name="b2")
out = tf.nn.softmax(tf.matmul(h_1, w_2) + b_2)

y = tf.placeholder(tf.float32, [None, 3])
loss = tf.reduce_mean(tf.square(y - out))
train_step = tf.train.GradientDescentOptimizer(0.5).minimize(loss)

init = tf.global_variables_initializer()

with tf.Session() as sess:
  sess.run(init)

  for i in range(10000):
    step = i + 1

    indices = np.random.randint(len(data), size=BATCH_SIZE)
    batch_data = data[indices]
    batch_label = label[indices]
    sess.run(train_step, feed_dict={x:batch_data, y:batch_label})
