#!/bin/bash
# Exit on error
set -e

# Resolve the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run the Ruby IRB session preloading presidio_client
ruby "$SCRIPT_DIR/irb_session.rb"
