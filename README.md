# Flask Server

A server implementation with Flask.

## Requirements

- Python 3
- [Configured .env file](../README.md)

## How to run

1. Update the API keys in the `server.py` file. Naturally, these should be in environment variables or key vaults.

2. Create and activate a new virtual environment
```
python3 -m venv env
source env/bin/activate
```

3. Install dependencies
```
pip3 install -r requirements.txt
```

4. Run the application

**MacOS / Unix**

```
python3 server.py
```

# iOS Client
After running the sample server:

1. Run `pod install` to install the Stripe iOS SDK.
2. Open `AcceptAPayment.xcworkspace`
3. Build and run the project in the iOS simulator.
