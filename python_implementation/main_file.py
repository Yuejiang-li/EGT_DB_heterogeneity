import DBupdateProcess as db
import time
import matplotlib.pyplot as plt

if __name__ == "__main__":
    start = time.time()
    mean_result = db.simDB_control(0.6, 0.8, 0.4, 400, 1, 0.1, 0.01, 'regular', (1000, 20), 5, 96)
    over = time.time()
    print("time consuming: ", over - start)
    plt.plot(mean_result)
    plt.show()