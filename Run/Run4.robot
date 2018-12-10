*** Settings ***
Library    Selenium2Library    run_on_failure=nothing
Library    Collections
Library    String    
Library    ../Source/CSV.py
Resource    ../Source/AllSource.robot
Suite Setup    Open Browser    https://vicare.vn/    chrome
Suite Teardown    Close All Browsers
Force Tags    all
*** Test Cases ***
# Get Services
    # Get All Services Data
    
# Get Services Types
    # Get Service Type
    
# Get Specialities Type
    # Get Specialities Type

# Get Link Of Hopital
    # Maximize Browser Window
    # ${lis_run}=    Create List    Phòng khám
    # :FOR    ${item}    IN    @{lis_run}
    # \    Get List Link Hopital And Place Type For Location    ${item}
    # \    Log To Console    Done Run For ${item}    

# Get All Data3
    # Maximize Browser Window
    # RUN Get Hopital Datas    21855    DD    7285

Run Get Doctor Sources
    Maximize Browser Window
    Run Get Doctor Sources    15000    20000