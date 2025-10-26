#!/bin/bash

# Audio Bookshelf UI - Comprehensive Test Runner
# This script provides various options for running tests with different configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
COVERAGE=false
VERBOSE=false
WATCH=false
CATEGORY="all"
OUTPUT_FORMAT="compact"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Audio Bookshelf UI - Test Runner"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --coverage          Generate coverage report"
    echo "  -v, --verbose           Verbose output"
    echo "  -w, --watch             Watch mode (auto-rerun on changes)"
    echo "  -t, --category CATEGORY Test category (unit|widget|integration|all)"
    echo "  -f, --format FORMAT     Output format (compact|expanded|json)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                      # Run all tests"
    echo "  $0 -c                   # Run with coverage"
    echo "  $0 -t unit              # Run unit tests only"
    echo "  $0 -c -v                # Run with coverage and verbose output"
    echo "  $0 -w                   # Run in watch mode"
}

# Function to run tests
run_tests() {
    local test_command="flutter test"
    local test_args=""
    
    # Add category-specific paths
    case $CATEGORY in
        "unit")
            test_args="test/core/ test/domain/ test/application/"
            ;;
        "widget")
            test_args="test/presentation/"
            ;;
        "integration")
            print_warning "Integration tests have been removed due to stability issues"
            exit 0
            ;;
        "all")
            test_args="test/"
            ;;
        *)
            print_error "Invalid category: $CATEGORY"
            exit 1
            ;;
    esac
    
    # Add coverage if requested
    if [ "$COVERAGE" = true ]; then
        test_command="$test_command --coverage"
    fi
    
    # Add verbose if requested
    if [ "$VERBOSE" = true ]; then
        test_command="$test_command --verbose"
    fi
    
    # Add watch if requested
    if [ "$WATCH" = true ]; then
        test_command="$test_command --watch"
    fi
    
    # Add output format
    case $OUTPUT_FORMAT in
        "expanded")
            test_command="$test_command --reporter expanded"
            ;;
        "json")
            test_command="$test_command --reporter json"
            ;;
        "compact")
            test_command="$test_command --reporter compact"
            ;;
    esac
    
    # Add test arguments
    test_command="$test_command $test_args"
    
    print_status "Running: $test_command"
    eval $test_command
}

# Function to generate coverage report
generate_coverage_report() {
    if [ "$COVERAGE" = true ]; then
        print_status "Generating coverage report..."
        
        # Check if lcov is installed
        if ! command -v genhtml &> /dev/null; then
            print_warning "genhtml not found. Installing lcov..."
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y lcov
            elif command -v brew &> /dev/null; then
                brew install lcov
            else
                print_error "Please install lcov manually to generate HTML coverage reports"
                return 1
            fi
        fi
        
        # Generate HTML coverage report
        genhtml coverage/lcov.info -o coverage/html --quiet
        
        print_success "Coverage report generated at coverage/html/index.html"
        
        # Open coverage report if possible
        if command -v open &> /dev/null; then
            open coverage/html/index.html
        elif command -v xdg-open &> /dev/null; then
            xdg-open coverage/html/index.html
        fi
    fi
}

# Function to check test dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        print_error "Not in a Flutter project directory"
        exit 1
    fi
    
    # Check if test dependencies are installed
    if ! flutter pub get &> /dev/null; then
        print_error "Failed to get dependencies"
        exit 1
    fi
    
    print_success "Dependencies checked successfully"
}

# Function to clean up
cleanup() {
    print_status "Cleaning up..."
    
    # Remove temporary files
    rm -f coverage/lcov.info.bak
    
    print_success "Cleanup completed"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--coverage)
            COVERAGE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -w|--watch)
            WATCH=true
            shift
            ;;
        -t|--category)
            CATEGORY="$2"
            shift 2
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_status "Audio Bookshelf UI - Test Runner"
    print_status "Category: $CATEGORY"
    print_status "Coverage: $COVERAGE"
    print_status "Verbose: $VERBOSE"
    print_status "Watch: $WATCH"
    print_status "Format: $OUTPUT_FORMAT"
    echo ""
    
    # Check dependencies
    check_dependencies
    
    # Run tests
    run_tests
    
    # Generate coverage report if requested
    if [ "$COVERAGE" = true ]; then
        generate_coverage_report
    fi
    
    # Cleanup
    cleanup
    
    print_success "Test run completed successfully!"
}

# Run main function
main
