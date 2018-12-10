*** Settings ***
Library    Selenium2Library
Library    Collections
Library    String    
Library    CSV.py    

*** Keywords ***
Test Excel
    ${ls_doctor_link}=    Read Data File    SaveData\\DoctorLink.csv    2
    ${ls_doctor_id}=    Read Data File    SaveData\\DoctorLink.csv    0
    ${ls_hospital_d_id}=    Read File As String   SaveData\\HospitalDoctorID.csv
    ${number_duplicate}=    Set Variable    0
    Set Global Variable    ${ls_doctor_link}    ${ls_doctor_link}
    Set Global Variable    ${ls_doctor_id}      ${ls_doctor_id}
    Set Global Variable    ${ls_hospital_d_id}     ${ls_hospital_d_id}
    
    :FOR    ${i}    IN RANGE    999999
    \    ${link_count}=    Get Length    ${ls_doctor_link}
    \    Exit For Loop If    '${link_count}'=='0'
    \    ${duplicate}=    Count Values In List    ${ls_doctor_link}    @{ls_doctor_link}[0]
    \    ${number_duplicate}=    Evaluate    ${number_duplicate}+${duplicate}    
    \    Run Keyword If    '${duplicate}'=='0'    Run Keywords    Write File    SaveData\\DoctorLinkNew.csv    @{ls_doctor_id}[0]    @{ls_doctor_link}[0]
    \    ...        AND    Remove From List    ${ls_doctor_id}    0
    \    ...        AND    Remove From List    ${ls_doctor_link}    0
    \    Run Keyword If    '${duplicate}'!='0'    For Dupliacate Values     ${duplicate}    ${ls_doctor_link}    ${ls_doctor_id}   
    
    Write File Text    SaveData\\DoctorIDNew.csv    ${ls_hospital_d_id}
    Log To Console    ${number_duplicate} Number Of Duplicate    

For Dupliacate Values
    [Arguments]    ${duplicate}    ${ls_doctor_link}    ${ls_doctor_id}
    
    Write File    SaveData\\DoctorLinkNew.csv    @{ls_doctor_id}[0]    @{ls_doctor_link}[0]
    ${main_id}=    Set Variable    @{ls_doctor_id}[0]
    ${main_link}=    Set Variable    @{ls_doctor_link}[0]
    Remove From List    ${ls_doctor_id}    0
    Remove From List    ${ls_doctor_link}    0
    
    :FOR    ${i}    IN RANGE    1    ${duplicate}
    \    ${index}=    Get Index From List    ${ls_doctor_link}    ${main_link}
    \    ${dup_id}=    Set Variable    @{ls_doctor_id}[${index}]
    \    Remove From List    ${ls_doctor_id}    ${index}
    \    Remove From List    ${ls_doctor_link}    ${index}
    \    Replace Dup ID    ${main_id}    ${dup_id}
    
    Set Global Variable    ${ls_doctor_link}    ${ls_doctor_link}
    Set Global Variable    ${ls_doctor_id}      ${ls_doctor_id}
    
Replace Dup ID
    [Arguments]    ${main_id}    ${dup_id}
    
    ${contain}=    Run Keyword And Return Status    Should Contain    ${ls_hospital_d_id}    ${dup_id}
    ${ls_hospital_d_id}=    Run Keyword If    ${contain}    Replace String    ${ls_hospital_d_id}    ${dup_id}    ${main_id}    ELSE    Set Variable    ${ls_hospital_d_id}
    # ${list_count}=    Get Length    ${ls_hospital_d_id}
    # :FOR    ${i}    IN RANGE    0    ${list_count}
    # \    ${contain}=    Run Keyword And Return Status    Should Contain    @{ls_hospital_d_id}[${i}]    ${dup_id}
    # \    ${temp}=    Run Keyword If    ${contain}    Replace String    @{ls_hospital_d_id}[${i}]    ${dup_id}    ${main_id}    ELSE    Set Variable    @{ls_hospital_d_id}[${i}]
    # \    Run Keyword If    ${contain}    Set List Value    ${ls_hospital_d_id}    ${i}    ${temp}
    # \    Exit For Loop If    ${contain}
    Set Global Variable    ${ls_hospital_d_id}     ${ls_hospital_d_id}
    
    
    
      