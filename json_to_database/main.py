import sqlalchemy
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import Session
import json
import time
from hashlib import md5
import os

POSTGRES_URL = os.getenv("POSTGRES_URL")
PROM_FILE = os.getenv("PROM_FILE")


Base = declarative_base()

class Signal(Base):
    __tablename__ = "signals"


    id = Column(Integer, primary_key=True, autoincrement=True)
    tick = Column(Integer)

    tx_identifier = Column(String)
    surface = Column(String)
    signal_color = Column(String)
    signal_name = Column(String)
    signal_count = Column(Integer)

engine = sqlalchemy.create_engine(POSTGRES_URL)
Base.metadata.create_all(engine)


latest_digest = None

while True:
    with open(PROM_FILE, "r") as f:
        json_content = f.read()


    if md5(json_content.encode("utf8")).digest() != latest_digest:
        try:
            content = json.loads(json_content)

            tick = content[-1]["game_tick"]

            entries = []
            for signal in content[:-1]:
                entries.append(Signal(tick = tick, **signal))

            session = Session(engine)
            session.bulk_save_objects(entries)
            session.commit()
            session.close()
        except json.JSONDecodeError:
            pass

    time.sleep(2)
