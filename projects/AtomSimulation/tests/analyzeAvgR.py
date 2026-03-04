import matplotlib.pyplot as plt
import csv

millis = []
avgR = []

with open("avgR.csv", "r") as file:
    reader = csv.reader(file)
    header = next(reader)  # skip header row

    for row in reader:
        millis.append(float(row[0]) / 1000)
        avgR.append(float(row[1]))

plt.figure()
plt.plot(millis, avgR)
plt.xlabel("Time (secs)")
plt.ylabel("Average Radius")
plt.title("Average Radius vs Time")

plt.show()
