# pp = 1
# for i in range(1, 11):
#     pp *= 2
#     print(i, ": RGB <= dout", pp, ";", sep="")

# import random as rd
# for i in range(32):
#     print("            ", i, ": myRand = 32'd", rd.randint(0, 15), ";", sep="")
for i in range(0, 32, 4):
    print("BCD[{:d}:{:d}] = tmp % 10;\ntmp = (tmp - 10 * BCD[{:d}:{:d}]) / 10;".format(i+3, i, i+3, i))