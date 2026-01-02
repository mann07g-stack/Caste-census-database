import pandas as pd
from sklearn.ensemble import IsolationForest

def detect_anomalies(data):
    # 1. Safety: If no data, return empty
    if not data:
        return []

    df = pd.DataFrame(data)

    # 2. Safety: Ensure 'income' exists and handle missing values
    if 'income' not in df.columns:
        return []
    
    df['income'] = df['income'].fillna(0)

    # 3. Constraint: IsolationForest needs at least 2 records to compare
    if len(df) < 2:
        return []

    # 4. The ML Logic (Outlier Detection)
    # contamination=0.1 means "Flag the top 10% weirdest records"
    model = IsolationForest(contamination=0.1, random_state=42)
    
    # -1 means Anomaly, 1 means Normal
    df['anomaly'] = model.fit_predict(df[['income']])

    # 5. Return only the IDs of the weird rows
    return df[df['anomaly'] == -1]['id'].tolist()