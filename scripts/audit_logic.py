import os
import json
import sys

def audit_state_update(file_path, action, raw_data):
    """
    Validates the state update against governance rules.
    Returns True if authorized, False otherwise.
    """
    try:
        # 1. Basic JSON validation
        new_state = json.loads(raw_data)
        
        required_fields = ['status', 'agent']
        for field in required_fields:
            if field not in new_state:
                print(f"GOVERNANCE ERROR: Missing required field '{field}'")
                return False

        # 2. Existing State Comparison (if file exists)
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as f:
                try:
                    current_state = json.loads(f.read())
                except json.JSONDecodeError:
                    current_state = {}

            # Rule: Prevent unauthorized agent overwrites without ACK
            if current_state.get('agent') and current_state['agent'] != new_state['agent']:
                if not new_state.get('conflict_ack'):
                    print(f"CONFLICT: Agent '{new_state['agent']}' is attempting to overwrite Agent '{current_state['agent']}' without conflict_ack.")
                    return False

        return True

    except json.JSONDecodeError:
        print("GOVERNANCE ERROR: Data is not valid JSON.")
        return False
    except Exception as e:
        print(f"SYSTEM ERROR: {str(e)}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(1)

    target_path = sys.argv[1]
    target_action = sys.argv[2]
    
    # Retrieve data from environment variable to avoid shell quoting issues
    data_to_audit = os.environ.get('OC_SYNC_DATA', '')

    if audit_state_update(target_path, target_action, data_to_audit):
        sys.exit(0) # Authorized
    else:
        sys.exit(1) # Rejected
