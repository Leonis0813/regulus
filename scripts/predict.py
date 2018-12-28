import mysql.connector as mysql
import numpy as np
import tensorflow as tf
import os
import sys
import yaml

args = sys.argv
MODEL = args[1]
SETTINGS = yaml.load(open(os.path.dirname(os.path.abspath(args[0])) + '/settings.yml', 'r+'))
TMP_DIR = "/opt/scripts/tmp"

connection = mysql.connect(
  host = SETTINGS['mysql']['host'],
  user = SETTINGS['mysql']['user'],
  password = SETTINGS['mysql']['password'],
  database = SETTINGS['mysql']['database'],
)

cursor = connection.cursor(dictionary=True)
cursor.execute(
  'SELECT open FROM candle_sticks '\
  'WHERE pair = "USDJPY" AND '\
    'WEEKDAY(`to`) BETWEEN 0 AND 4 '\
  'ORDER BY `to` desc '\
  'LIMIT 300'
)

def open(candle_stick):
  return candle_stick['open']

def min_max(x):
  min = x.min(axis=0, keepdims=True)
  max = x.max(axis=0, keepdims=True)
  result = 2.0 * ((x - min) / (max - min) - 0.5)
  return result

vfunc = np.vectorize(open)
candle_sticks = vfunc(cursor.fetchall())
candle_sticks = min_max(candle_sticks)

x = tf.placeholder(tf.float32, [None, 300])

w_1 = tf.Variable(tf.truncated_normal([300, 100], stddev=0.1), name="w1")
b_1 = tf.Variable(tf.zeros([100]), name="b1")
h_1 = tf.nn.relu(tf.matmul(x, w_1) + b_1)

w_2 = tf.Variable(tf.truncated_normal([100, 3], stddev=0.1), name="w2")
b_2 = tf.Variable(tf.zeros([3]), name="b2")
out = tf.nn.softmax(tf.matmul(h_1, w_2) + b_2)

saver = tf.train.Saver()

with tf.Session() as sess:
  saver.restore(sess, TMP_DIR + "/model.ckpt")
  open(TMP_DIR + "/result.txt", mode='w').write(sess.run(out, feed_dict={x:candle_sticks}))
