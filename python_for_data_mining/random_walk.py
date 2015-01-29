'''
A two-dimensional random walk simulator and animator.
'''

# The turtle package is part of Python's standard library. It provides some
# very primitive graphics capabilities. For more details see
#
#   https://docs.python.org/3/library/turtle.html
#
import turtle

import numpy as np

def random_walk(n, x_start = 0, y_start = 0, p = 0.25):
    ''' Simulate a two-dimensional random walk.

    Args:
        n           number of steps

    Returns:
        Two Numpy arrays containing the x and y coordinates, respectively, at
        each step (including the initial position).
    '''
    # Your task: fill this in.
    if type(p) is float and (p - 0.25 < 0.001):
        p1 = p2 = [0.5] *2 
    elif len(p) == 4 and (sum(p) - 1 < 0.001):
        p1 = [p[0]+p[3], p[1]+p[2]] # Break into 1 -1 and direction
        p2 = [p[2]+p[3], p[1]+p[0]]
    else:
        raise ValueError('p does not have length 4!')
    # Wheather up/right or left/down
    ones = np.random.choice([1, -1], replace = True, size = n, p = p1) 
    direc = np.random.choice([True, False], replace = True, size = n, p = p2)
    #choose up/down or left/right (0, +/- 1) or (+/-1, 0)
    xs = np.where(direc, ones, 0) ; ys = np.where(direc, 0, ones)
    x = xs.cumsum() + x_start ; y = ys.cumsum() + y_start
    return x, y



# Notice that the documentation automatically shows up when you use ?
def draw_walk(x, y, speed = 'slowest', scale = 20):
    ''' Animate a two-dimensional random walk.

    Args:
        x       x positions
        y       y positions
        speed   speed of the animation
        scale   scale of the drawing
    '''
    # Reset the turtle.
    turtle.reset()
    turtle.speed(speed)
    # Combine the x and y coordinates.
    walk = zip(x * scale, y * scale)
    start = next(walk)
    # Move the turtle to the starting point.
    turtle.penup()
    turtle.goto(*start)
    # Draw the random walk.
    turtle.pendown()
    for _x, _y in walk:
        turtle.goto(_x, _y)

