from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional
from model import detect_anomalies # Import your brain

app = FastAPI()

class CensusData(BaseModel):
    id: str
    householdId: str
    income: Optional[float] = 0

@app.post("/ai/verify")
def verify_census(data: List[CensusData]):
    # 1. Convert Pydantic objects (Java data) to simple Python Dictionaries
    # The model needs a list of dicts: [{'id': '...', 'income': 100}, ...]
    clean_data = [item.dict() for item in data]

    # 2. Let the model find the weird ones
    flagged_ids = detect_anomalies(clean_data)
            
    return {"flagged_records": flagged_ids}
# from fastapi import FastAPI
# from model import detect_anomalies

# app = FastAPI()

# @app.post("/ai/verify")
# def verify_census(data: list):
#     flagged_ids = detect_anomalies(data)
#     return {
#         "flagged_records": flagged_ids
#     }
