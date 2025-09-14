#!/bin/bash

# =============================================================================
# Todo App API Testing - Master Test Runner
# =============================================================================

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_BASE="http://localhost:5000/api"
JSON_SERVER="http://localhost:3001"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TEST_RESULTS=()

# Function to print headers
print_header() {
    echo -e "${PURPLE}"
    echo "============================================================================="
    echo "$1"
    echo "============================================================================="
    echo -e "${NC}\n"
}

# Function to print section headers
print_section() {
    echo -e "${CYAN}--- $1 ---${NC}"
}

# Function to check if server is running
check_server() {
    local server_url="$1"
    local server_name="$2"
    
    if curl -s --connect-timeout 5 "$server_url" > /dev/null; then
        echo -e "${GREEN}✅ $server_name is running${NC}"
        return 0
    else
        echo -e "${RED}❌ $server_name is not running${NC}"
        return 1
    fi
}

# Function to run test script
run_test_script() {
    local script_name="$1"
    local description="$2"
    local script_path="${SCRIPT_DIR}/${script_name}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    print_section "Running: $description"
    
    if [ -f "$script_path" ]; then
        if chmod +x "$script_path" && bash "$script_path"; then
            echo -e "${GREEN}✅ PASSED: $description${NC}\n"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            TEST_RESULTS+=("✅ PASSED: $description")
        else
            echo -e "${RED}❌ FAILED: $description${NC}\n"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            TEST_RESULTS+=("❌ FAILED: $description")
        fi
    else
        echo -e "${RED}❌ SCRIPT NOT FOUND: $script_path${NC}\n"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        TEST_RESULTS+=("❌ SCRIPT NOT FOUND: $description")
    fi
    
    echo -e "${YELLOW}⏱️  Waiting 2 seconds before next test...${NC}\n"
    sleep 2
}

# Function to print test summary
print_summary() {
    print_header "TEST EXECUTION SUMMARY"
    
    echo -e "${BLUE}📊 Test Statistics:${NC}"
    echo -e "   Total Tests: $TOTAL_TESTS"
    echo -e "   Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "   Failed: ${RED}$FAILED_TESTS${NC}"
    
    if [ $TOTAL_TESTS -gt 0 ]; then
        local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
        echo -e "   Success Rate: ${YELLOW}${success_rate}%${NC}\n"
    fi
    
    echo -e "${BLUE}📋 Detailed Results:${NC}"
    for result in "${TEST_RESULTS[@]}"; do
        echo -e "   $result"
    done
    
    echo -e "\n"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 ALL TESTS PASSED! 🎉${NC}"
    else
        echo -e "${RED}⚠️  SOME TESTS FAILED ⚠️${NC}"
        echo -e "${YELLOW}Please check the output above for details.${NC}"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all          Run all test suites (default)"
    echo "  --auth         Run authentication tests only"
    echo "  --users        Run user management tests only" 
    echo "  --todos        Run todo management tests only"
    echo "  --categories   Run category management tests only"
    echo "  --json-server  Run JSON server tests only"
    echo "  --quick        Run a quick subset of tests"
    echo "  --help         Show this help message"
    echo ""
    echo "Prerequisites:"
    echo "  - Express API server running on http://localhost:5000"
    echo "  - JSON Server running on http://localhost:3001"
    echo ""
}

# Function to run quick tests (minimal subset)
run_quick_tests() {
    print_header "QUICK TEST SUITE"
    
    # Just run health checks and basic auth
    print_section "Server Health Checks"
    check_server "$API_BASE/health" "Express API Server"
    check_server "$JSON_SERVER/db" "JSON Server"
    
    echo -e "\n"
    
    # Run only auth test
    run_test_script "test-auth.sh" "Authentication Tests (Quick)"
    
    print_summary
}

# Main execution
main() {
    local test_mode="all"
    
    # Parse command line arguments
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --auth)
            test_mode="auth"
            ;;
        --users)
            test_mode="users"
            ;;
        --todos)
            test_mode="todos"
            ;;
        --categories)
            test_mode="categories"
            ;;
        --json-server)
            test_mode="json-server"
            ;;
        --quick)
            test_mode="quick"
            ;;
        --all|"")
            test_mode="all"
            ;;
        *)
            echo -e "${RED}Invalid option: $1${NC}"
            show_usage
            exit 1
            ;;
    esac
    
    print_header "TODO APP API TESTING SUITE"
    
    echo -e "${BLUE}📋 Configuration:${NC}"
    echo -e "   API Base URL: $API_BASE"
    echo -e "   JSON Server URL: $JSON_SERVER"
    echo -e "   Test Mode: $test_mode"
    echo -e "   Script Directory: $SCRIPT_DIR\n"
    
    # Handle quick test mode
    if [ "$test_mode" = "quick" ]; then
        run_quick_tests
        exit $FAILED_TESTS
    fi
    
    # Check server availability
    print_section "Pre-flight Server Checks"
    SERVER_CHECK_FAILED=0
    
    if ! check_server "$API_BASE/health" "Express API Server"; then
        SERVER_CHECK_FAILED=1
    fi
    
    if ! check_server "$JSON_SERVER/db" "JSON Server"; then
        SERVER_CHECK_FAILED=1
    fi
    
    if [ $SERVER_CHECK_FAILED -eq 1 ]; then
        echo -e "\n${RED}⚠️  Server check failed. Please ensure both servers are running:${NC}"
        echo -e "${YELLOW}   Express Server: npm start (in Back-End folder)${NC}"
        echo -e "${YELLOW}   JSON Server: npm start (in Database folder)${NC}\n"
        
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Exiting...${NC}"
            exit 1
        fi
    fi
    
    echo -e "\n"
    
    # Run tests based on mode
    case "$test_mode" in
        "all")
            print_header "RUNNING ALL TEST SUITES"
            run_test_script "test-auth.sh" "Authentication Tests"
            run_test_script "test-users.sh" "User Management Tests"
            run_test_script "test-todos.sh" "Todo Management Tests"
            run_test_script "test-categories.sh" "Category Management Tests"
            run_test_script "test-json-server.sh" "JSON Server & Relations Tests"
            ;;
        "auth")
            print_header "AUTHENTICATION TESTS ONLY"
            run_test_script "test-auth.sh" "Authentication Tests"
            ;;
        "users")
            print_header "USER MANAGEMENT TESTS ONLY"
            run_test_script "test-users.sh" "User Management Tests"
            ;;
        "todos")
            print_header "TODO MANAGEMENT TESTS ONLY"
            run_test_script "test-todos.sh" "Todo Management Tests"
            ;;
        "categories")
            print_header "CATEGORY MANAGEMENT TESTS ONLY"
            run_test_script "test-categories.sh" "Category Management Tests"
            ;;
        "json-server")
            print_header "JSON SERVER TESTS ONLY"
            run_test_script "test-json-server.sh" "JSON Server & Relations Tests"
            ;;
    esac
    
    # Print final summary
    print_summary
    
    # Clean up temporary files
    rm -f /tmp/todo_app_token.txt
    
    # Exit with error code if any tests failed
    exit $FAILED_TESTS
}

# Execute main function with all arguments
main "$@"