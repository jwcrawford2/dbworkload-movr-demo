import datetime as dt
import psycopg
import random
import time
from uuid import uuid4


class Fd:
    def __init__(self, args: dict):
        # args is a dict of string passed with the --args flag
        
        self.think_time: float = float(args.get("think_time", 5) / 1000)

        # you can arbitrarely add any variables you want
        self.my_var = 1

        # translation table for efficiently generating a string
        # -------------------------------------------------------
        # make translation table from 0..255 to A..Z, 0..9, a..z
        # the length must be 256
        self.tbl = bytes.maketrans(
            bytearray(range(256)),
            bytearray(
                [ord(b"a") + b % 26 for b in range(113)]
                + [ord(b"0") + b % 10 for b in range(30)]
                + [ord(b"A") + b % 26 for b in range(113)]
            ),
        )

    # the setup() function is executed only once
    # when a new executing thread is started.
    # Also, the function is a vector to receive the excuting threads's unique id and the total thread count
    def setup(self, conn: psycopg.Connection, id: int, total_thread_count: int):
        with conn.cursor() as cur:
            print(
                f"My thread ID is {id}. The total count of threads is {total_thread_count}"
            )
            print(cur.execute(f"select version()").fetchone()[0])

    # the loop() function returns a list of functions
    # that dbworkload will execute, sequentially.
    # Once every func has been executed, loop() is re-evaluated.
    # This process continues until dbworkload exits.
    def loop(self):
        return [
            self.txn_0,
            self.txn_1,
        ]

    #####################
    # Utility Functions #
    #####################
    def __think__(self, conn: psycopg.Connection):
        time.sleep(self.think_time)

    def random_str(self, size: int = 12):
        return (
            random.getrandbits(8 * size)
            .to_bytes(size, "big")
            .translate(self.tbl)
            .decode()
        )

    # Workload function stubs
    
    def txn_0(self, conn: psycopg.Connection):
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT id,
                FROM file_data
                WHERE region = %s
                  AND id = %s
                  FOR
                  UPDATE
                """,
                (
                    # add bind parameter,
                    # add bind parameter, 
                ), 
            ).fetchall()
    
    def txn_1(self, conn: psycopg.Connection):
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE file_data
                SET postmark = now()
                WHERE region = 'westus2'
                  AND id = 324234234234
                """,
                ( 
                ), 
            )
    

'''
# Quick random generators reminder

# random string of 25 chars
self.random_str(25),

# random int between 0 and 100k
random.randint(0, 100000),

# random float with 2 decimals 
round(random.random()*1000000, 2)

# now()
dt.datetime.utcnow()

# random timestamptz between certain dates,
# expressed as unix ts
dt.datetime.fromtimestamp(random.randint(1655032268, 1759232268))

# random UUID
uuid4()

# random bytes
size = 12
random.getrandbits(8 * size).to_bytes(size, "big")

'''