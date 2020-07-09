# pp = 1
# for i in range(1, 11):
#     pp *= 2
#     print(i, ": RGB <= dout", pp, ";", sep="")

import random as rd
for i in range(32):
    print("            ", i, ": myRand = 32'd", rd.randint(0, 15), ";", sep="")