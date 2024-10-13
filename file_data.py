import datetime as dt
import psycopg
import random
import time
import uuid


class File_data:
    def __init__(self, args: dict):
        # args is a dict of string passed with the --args flag
        # user passed a yaml/json, in python that's a dict object

        self.read_pct: float = float(args.get("read_pct", 90) / 100)
        self.region: str = ""
        self.ids: []

    # the setup() function is executed only once
    # when a new executing thread is started.
    # Also, the function is a vector to receive the excuting threads's unique id and the total thread count
    def setup(self, conn: psycopg.Connection, id: int, total_thread_count: int):
        with conn.cursor() as cur:
            # print(
            #     f"My thread ID is {id}. The total count of threads is {total_thread_count}"
            # )
            # print(cur.execute(f"select version()").fetchone()[0])
            # print(cur.execute(f"select min(id), max(id) from file_data").fetchone()[0])
            self.region = cur.execute(f"select gateway_region()").fetchone()[0]
            print(f"Running in region: {self.region}")
            # cur.execute(f"SELECT id FROM file_data where region = %s::crdb_internal_region limit 10000",(self.region))
            # read file_data records // if the current region is centralus, we can select any rows from file_data// if the region is westus2 or eastus2 only read records from that region
            cur.execute("SELECT id FROM file_data WHERE ((%(region)s = 'centralus' and region = 'westus2') or (%(region)s != 'centralus' and region = %(region)s::crdb_internal_region)) limit 100000", {'region': self.region,})
            self.ids = [row[0] for row in cur.fetchall()] 
            # print(self.ids)

    # the run() function returns a list of functions
    # that dbworkload will execute, sequentially.
    # Once every func has been executed, run() is re-evaluated.
    # This process continues until dbworkload exits.
    def loop(self):
        if random.random() < self.read_pct:
            return [self.read]
        return [self.update]

    # conn is an instance of a psycopg connection object
    # conn is set by default with autocommit=True, so no need to send a commit message
    def read(self, conn: psycopg.Connection):
        with conn.cursor() as cur:
            stmt = """
                SELECT application, email, name, formatted, postmark FROM file_data AS OF SYSTEM TIME follower_read_timestamp() WHERE id = %s and region = %s; 
                """
            cur.execute(stmt, (random.choice(self.ids),self.region))
            cur.fetchone()


    def update(self, conn: psycopg.Connection):
        with conn.cursor() as cur:
            stmt = """
                update file_data set formatted = TRUE, postmark = now() where id = %s;
                """
            cur.execute(stmt, (random.choice(self.ids),))



