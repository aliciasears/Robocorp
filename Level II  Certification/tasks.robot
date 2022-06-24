*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.FileSystem
Library             RPA.Tables
Library             RPA.Archive
Library             RPA.HTTP
Library             RPA.PDF
Library    RPA.Robocloud.Items


*** Variables ***    
${Pathy}=    C:${/}Users${/}absear${/}OneDrive - Emerson${/}2019 Intelligent Automation Program Manager Role${/}Training${/}Robocorp Training${/}Level II  Certification${/}orders.csv
${receipts}=    C:${/}Users${/}absear${/}OneDrive - Emerson${/}2019 Intelligent Automation Program Manager Role${/}Training${/}Robocorp Training${/}Level II  Certification${/}output${/}receipts


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${tickets}=    Download CSV files
    Open the robot order website
    FOR    ${row}    IN    @{tickets}
        Pop-ups
        Fill orders    ${row}
        Preview
        Wait Until Keyword Succeeds    45    5s    Order
        ${screenshot}=    Save screenshot    ${row}[Order number]
        ${PDF}=    Saved PDF    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${row}[Order number]
        Delete saved image    ${row}[Order number]
        Place a new order
        Log    ${row}
        
    END  
    Zip orders

*** Keywords ***
Open the robot order website
    Open Chrome Browser    https://robotsparebinindustries.com/#/robot-order    maximized=True    
Pop-ups
    Wait Until Element Is Visible    css:div.modal
    Click Button    OK
Download CSV files
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${Table}=    Read table from CSV    orders.csv
    [Return]    ${table}
Fill orders
    [Arguments]    ${fill}
    Select From List By Value    id:head    ${fill}[Head]
    Select Radio Button    body    ${fill}[Body]
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${fill}[Legs]
    Input Text    id:address    ${fill}[Address]
Preview
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image
Order
    Wait Until Element Is Visible    id:robot-preview-image
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt
Save screenshot
    [Arguments]    ${id}
    Screenshot    id:robot-preview-image    ${receipts}${/}Order_Number${id}.png
Saved PDF
    [Arguments]    ${id}
    Wait Until Element Is Visible    id:receipt
    ${receiptsHTML}=    Get Element Attribute    id:receipt    outerHTML    
    Html To Pdf    ${receiptsHTML}    ${receipts}${/}Order_Number${id}.pdf
Create PDF
    Html To Pdf    id:receipt    ${receipts}${/}file1.png
Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${id}
    Open Pdf    ${receipts}${/}Order_Number${id}.pdf
    Add Watermark Image To Pdf    ${receipts}${/}Order_Number${id}.png    ${receipts}${/}Order_Number${id}.pdf
    Close Pdf    ${receipts}${/}Order_Number${id}.pdf
Place a new order
    Click Button    id:order-another
Delete saved image
    [Arguments]    ${id}
    Remove File    ${receipts}${/}Order_Number${id}.png    missing_ok=True

Zip orders
    Archive Folder With Zip    ${receipts}    receipts.zip    