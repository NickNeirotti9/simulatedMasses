import random
import math
import matplotlib.pyplot as plt

# radius of the circle. 20mm = 0.393701, 10mm = 0.196851
circle_r = 0.393701
# center of the circle (x, y)
circle_x = 0
circle_y = 0
numPoints = 14

x_coordinates = []
y_coordinates = []

for i in range(numPoints):
    #random angle
    alpha = 2 * math.pi * random.random()
    #random radius
    r = circle_r * math.sqrt(random.random())
    # calculating coordinates
    x = r * math.cos(alpha) + circle_x
    x_coordinates.append(x)
    y = r * math.sin(alpha) + circle_y
    y_coordinates.append(y)
    #print("Calc #" + str(i) + " (" + str(x) + ", " + str(y) + ")")

#draws exterior cluster circle, replace cluster size
circle1 = plt.Circle((0, 0), circle_r, color='b', fill=False)
fig, ax = plt.subplots()
ax.add_patch(circle1)

#for 20mm clusters to determine which calcs should be larger
alphac = 2 * math.pi * random.random()
rc = (circle_r/2) * math.sqrt(random.random())
xc = rc * math.cos(alphac) + circle_x
yc = rc * math.sin(alphac) + circle_y
circle2 = plt.Circle((xc, yc), 0.196851, color='r', fill=False)
ax.add_patch(circle2)

#plots x & y coordinates from list
ax.scatter(x_coordinates, y_coordinates, color='black')

plt.axis('square')
plt.xlim(-0.393701,0.393701)
plt.ylim(-0.393701,0.393701)
plt.show()
