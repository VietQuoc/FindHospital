*** Settings ***
Library    Selenium2Library
Library    Collections
Library    String    
Library    ../Source/CSV.py
Resource    ../Source/AllSource.robot
Resource    ../Source/ExcelResource.robot
*** Test Cases ***
Test
    Test Excel