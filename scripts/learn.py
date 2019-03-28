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
Settings = yaml.load(open(os.path.dirname(os.path.abspath(args[0])) + '/settings.yml', 'r+'))

connection = mysql.connect(
  host = Settings['mysql']['host'],
  user = Settings['mysql']['user'],
  password = Settings['mysql']['password'],
  database = Settings['mysql']['database'],
)

cursor = connection.cursor(dictionary=True)
cursor.execute(
  'SELECT value FROM moving_averages '\
  'WHERE `time` BETWEEN "' + FROM + '" AND "' + TO + '" AND '\
    'pair = "USDJPY" AND '\
    'time_frame = "H1" AND '\
    'period = 25'\
  'ORDER BY `time`'
)

def value(moving_average):
  return moving_average['value']

def min_max(x):
  min = x.min(axis=0, keepdims=True)
  max = x.max(axis=0, keepdims=True)
  result = 2.0 * ((x - min) / (max - min) - 0.5)
  return result

vfunc = np.vectorize(value)
moving_averages = vfunc(cursor.fetchall())
moving_averages = min_max(moving_averages)

data = np.empty((0, 300), float)
label = np.empty((0, 3), int)

for i in range(0, len(moving_averages) - 450, 150):
  if (moving_averages[i+300] + 0.01) < moving_averages[i+450]:
    label = np.append(label, np.array([[1,0,0]]), axis=0)
  elif (moving_averages[i+300] - 0.01 ) > moving_averages[i+450]:
    label = np.append(label, np.array([[0,1,0]]), axis=0)
  else:
    label = np.append(label, np.array([[0,0,1]]), axis=0)

  data = np.append(data, np.array([moving_averages[i:i+300]]), axis=0)

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

saver = tf.train.Saver()

with tf.Session() as sess:
  sess.run(init)

  for i in range(10000):
    step = i + 1

    indices = np.random.randint(0, len(data), int(BATCH_SIZE), int)
    batch_data = data[indices]
    batch_label = label[indices]
    sess.run(train_step, feed_dict={x:batch_data, y:batch_label})

  saver.save(sess, "/opt/scripts/tmp/model.ckpt")
