*** Settings ***
Library    Selenium2Library
Library    Collections
Library    String    
Library    CSV.py    
Library    Image.py      
Library    Utils.py          

*** Variables ***
${COUNTY_LIST}    //h3[normalize-space()='TÌM KIẾM BỆNH VIỆN THEO QUẬN']/following-sibling::ul[contains(@class,'search_common_box')]//li
${HOPITAL_LINK}    //div[@class='result_item_box']//div[contains(@class,'pc-display')]//a

${HOS_NAME}        //h1[@class='hos_name']
${IMAGE}           //img[@class='img-responsive']
${PHONE_SHOW}      //a[@id='phoneShow']
${PHONE_NUMBER}    //span[@id='phoneNumber']
${ADDRESS}         //div[@class='adress']
${HOUR}            //ul[@class='working_time']
${WEB_LINK}        //div[contains(@class,'link-web')]//a
${UTILITIES}       //div[@class='tb_location']//span[contains(@class,'utilities-active')]
#--------------------------------------------------------------------------------------------------
${DICH_VU_NUMBER_PAGE_XPATH}        //span[@class='current']
${DICH_VU_NAME_XPATH}               //div[@id='service-list']//article//h3/a
${GET_LOAI_CO_SO}                   (//span[@itemprop='title'])[last()]/ancestor::li[1]/preceding-sibling::li[1]//span
${LOAI_CO_SO_BUTTON}                //a[contains(@class,'icon-place_types')]
${TINH_THANH_BUTTON}                //a[contains(@class,'icon-provinces')]
${TINH_THANH_CHECKBOX}              //div[@id='tab-provinces']//span[normalize-space()='$$']/preceding-sibling::input[@type='checkbox']
${LOC_DANH_SACH_BUTTON}             //button[@type='submit' and normalize-space()='Lọc danh sách']
${LOAI_CO_SO_CHECKBOX}              //div[@id='tab-place_types']//span[normalize-space()='$$']/preceding-sibling::input[@type='checkbox']
${LOAI_CO_SO_NAME}                  //div[@id='tab-place_types']//input[@type='checkbox']/following-sibling::span

${CHUYEN_KHOA_BUTTON}               //a[contains(@class,'icon-specialities')]
${CHUYEN_KHOA_NAME}                 //div[@id='tab-specialities']//input[@type='checkbox']/following-sibling::span

${LIST_COSO_XPATH}                  //div[@class='info']//h2/a


${PHONE_NUMBER_XPATH}               xpath=(//i[contains(@class,'fa-phone-square')]/following-sibling::strong/a)[last()]
${HOPITAL_ADDRESS_XPATH}            xpath=(//span[@itemprop='streetAddress'])[last()]
${HOPITAL_HOUR_XPATH}               xpath=(//i[contains(@class,'fa-clock-o')]/ancestor::div[1][not(normalize-space()='0 Trả lời - 0 Cảm ơn')])[last()]
${HOPITAL_RATING}                   //span[contains(@class,'star-ratings')]/following-sibling::strong
${HOPITAL_INFO_XPATH}               //a[normalize-space()='Thông tin chi tiết']
${HOPITAL_INFO_MORE_BUTTON}         xpath=(//div[contains(@class,'description')]//span[@class='readmore-trigger-collapsing']/a)[last()]
${HOPITAL_INFO_TEXT}                //div[@class='full-version']//div[contains(@class,'description')]/p
${HOPITAL_SPECIAL_LIST}             //div[@class='collapsible-header' and contains(normalize-space(),'Chuyên khoa')]/following-sibling::div//li
${HOPITAL_SERVICE_LIST}             //div[@class='collapsible-header' and contains(normalize-space(),'Dịch vụ')]/following-sibling::div//li
${HOPITAL_DOCTOR_LIST}              //div[@class='collapsible-header' and contains(normalize-space(),'Đội ngũ')]/following-sibling::div//article//h4/a
${HOPITAL_IMAGE}                    //a[@itemprop='image']
*** Keywords ***
Get County And Link
    Go To    https://timbenhvien.vn/
    Wait Until Page Contains Element    ${COUNTY_LIST}
    ${count}=    Get Element Count    ${COUNTY_LIST}
    :FOR    ${i}    IN RANGE    1    ${count}+1
    \    ${text}=    Get Text    xpath=(${COUNTY_LIST})[${i}]
    \    ${link}=    Get Element Attribute    xpath=(${COUNTY_LIST})[${i}]//a    href
    \    Write File    County.CSV     ${text}    ${link}

Get Page Link
    [Arguments]    ${number_run}
    ${ls_county}=    Read Data File    County.CSV    0
    ${ls_link}=    Read Data File    County.CSV    1
    
    ${number_hopital_temp}=    Split String    @{ls_county}[${number_run}]    (
    ${number_hopital_temp2}=    Split String    @{number_hopital_temp}[1]    )
    ${number_hopital}=    Set Variable    @{number_hopital_temp2}[0]
    ${number_hopital}=    Convert To Integer    ${number_hopital}
    ${number_page}=    Evaluate    ${number_hopital}/20
    ${number_page}=    Convert To Integer    ${number_page}
    ${div}=    Evaluate    ${number_hopital}%20
    
    
    :FOR    ${i}    IN RANGE    1    ${number_page}+1
    \    ${page_link}=    Set Variable    @{ls_link}[${number_run}]/trang:${i}
    \    Write File    Page_Link_@{ls_county}[${number_run}].CSV     ${page_link}
    
    ${have_another_page}=    Evaluate    ${number_page}+1    
    ${page_link}=    Set Variable    @{ls_link}[${number_run}]/trang:${have_another_page}
    Run Keyword If    ${div}>0    Write File    Page_Link_@{ls_county}[${number_run}].CSV     ${page_link}    

Get Hopital Link
    [Arguments]    ${number_run}
    
    ${ls_county}=    Read Data File    County.CSV    0
    ${read_file_name}=    Set Variable    Page_Link_@{ls_county}[${number_run}].CSV
    ${write_file_name}=    Set Variable    Link_@{ls_county}[${number_run}].CSV
    
    ${ls_page_link}=    Read Data File    ${read_file_name}    0
    :FOR    ${link}    IN    @{ls_page_link}
    \    Go To    ${link}
    \    Get 20 Link On Page    ${write_file_name}
    
Get 20 Link On Page
    [Arguments]    ${write_file_name}
    Wait Until Page Contains Element    ${HOPITAL_LINK}
    ${ls_element}=    Get WebElements    ${HOPITAL_LINK}
    :FOR    ${element}    IN    @{ls_element}
    \    ${li}=    Get Element Attribute    ${element}    href
    \    Write File    ${write_file_name}     ${li}

Get All Data Of One County
    [Arguments]    ${number_run}
    
    ${ls_county}=    Read Data File    County.CSV    0
    ${read_file_name}=    Set Variable    Link_@{ls_county}[${number_run}].CSV
    ${write_file_name}=    Set Variable    SaveData\\@{ls_county}[${number_run}].CSV
    
    ${ls_page_link}=    Read Data File    ${read_file_name}    0
    :FOR    ${link}    IN    @{ls_page_link}
    \    Run Keyword And Continue On Failure    Get All Data Of The Hopital    ${link}    ${write_file_name}

Get All Data Of The Hopital
    [Arguments]    ${link}    ${write_file_name}
    
    Go To    ${link}
    
    Wait Until Page Contains Element    ${HOS_NAME}
    ${name}=    Get Text    ${HOS_NAME}
    ${lsname}=    Split String    ${name}    \n
    
    ${file_name}=    Set Variable    SaveData\\Image\\@{lsname}[0]
    Wait Until Page Contains Element    ${IMAGE}
    ${image_source}=    Get Element Attribute    ${IMAGE}    src
    Download File    ${image_source}    ${file_name}
    
    Wait Until Page Contains Element    ${PHONE_SHOW}    1s
    Click Element    ${PHONE_SHOW}
    ${phone}=    Get Text    ${PHONE_NUMBER}
    
    Wait Until Page Contains Element    ${ADDRESS}    1s
    ${adr}=    Get Text    ${ADDRESS}
    
    ${have_hour}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${HOUR}    1s
    ${ho}=    Run Keyword If    ${have_hour}    Get Text    ${HOUR}
    ...                 ELSE    Set Variable    ${EMPTY}
    
    ${have_web}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${WEB_LINK}    1s
    ${wb}=    Run Keyword If    ${have_web}    Get Element Attribute    ${WEB_LINK}    href
    ...                 ELSE    Set Variable    ${EMPTY}
    
    
    ${ls_utilities}=    Get WebElements    ${UTILITIES}
    ${ul}=    Set Variable    ${EMPTY}
    ${i}=    Set Variable    1
    :FOR    ${element}    IN    @{ls_utilities}
    \    ${text}=    Get Text    ${element}
    \    ${ul}=    Set Variable If    '${i}'=='1'    ${text}    ${ul}\n${text}
    \    ${i}=    Evaluate    ${i}+1    
    Write File    ${write_file_name}     "@{lsname}[0]"    "${phone}"    "${adr}"    "${ho}"    "${wb}"    "${ul}"    "@{lsname}[0].jpg"


Get All Services Data
    Write File    SaveData\\DichVu.csv    UniqueID    Ten Dich Vu
    Go To    https://vicare.vn/dich-vu/?q=
    Wait Until Page Contains Element    ${DICH_VU_NUMBER_PAGE_XPATH}
    ${page_text}=    Get Text    ${DICH_VU_NUMBER_PAGE_XPATH}
    ${page_text}=    Replace String    ${page_text}    Trang 1 /     ${EMPTY}
    ${page_text}=    Convert To Integer    ${page_text}
    
    :FOR    ${i}    IN RANGE    1    ${page_text}+1
    \    Get Service Of One Page    ${i}
    \    Run Keyword If    (${i}%500)==0    Clear Memory
    
    
Get Service Of One Page
    [Arguments]    ${page_number}
    
    Go To    https://vicare.vn/dich-vu/?q=&page=${page_number}
    
    ${index_number}=    Evaluate    (${page_number}-1)*10
    ${text_id}=    Run Keyword If    ${index_number}<10    Set Variable    0000    
    ...    ELSE    Run Keyword If    ${index_number}<100    Set Variable    000
    ...    ELSE    Run Keyword If    ${index_number}<1000    Set Variable    00
    ...    ELSE    Run Keyword If    ${index_number}<10000    Set Variable    0
    ...    ELSE    Set Variable    ${EMPTY}
    
    ${ls_sv}=    Get WebElements    ${DICH_VU_NAME_XPATH}
    :FOR    ${element}    IN    @{ls_sv}
    \    ${text}=    Get Text    ${element}
    \    ${id}=    Convert To String    ${text_id}
    \    ${id}=    Set Variable    ${id}${index_number}
    \    Write File    SaveData\\DichVu.csv    ${id}    ${text}
    \    ${index_number}=    Evaluate    ${index_number}+1    

Get Service Type
    Write File    SaveData\\LoaiDichVu.csv    UniqueID    Loai Dich Vu
    
    Go To    https://vicare.vn/danh-sach/ca-nuoc/
    
    Wait Until Page Contains Element    ${LOAI_CO_SO_BUTTON}
    Click Element    ${LOAI_CO_SO_BUTTON}
    ${ls_element}=    Get WebElements    ${LOAI_CO_SO_NAME}
    ${i}=    Set Variable    1
    :FOR    ${elemnt}    IN    @{ls_element}
    \    ${id}=    Set Variable If    ${i}<10    0${i}    ${i}
    \    ${id}=    Convert To String    ${id}
    \    ${text}=    Get Text    ${elemnt}
    \    Write File    SaveData\\LoaiDichVu.csv    "T${id}"    "${text}"
    \    ${i}=    Evaluate    ${i}+1    
    
Get Specialities Type
    Write File    SaveData\\ChuyenKHoa.csv    UniqueID    Chuyen Khoa
    
    Go To    https://vicare.vn/danh-sach/ca-nuoc/
    
    Wait Until Page Contains Element    ${CHUYEN_KHOA_BUTTON}
    Click Element    ${CHUYEN_KHOA_BUTTON}
    ${ls_element}=    Get WebElements    ${CHUYEN_KHOA_NAME}
    ${i}=    Set Variable    1
    :FOR    ${elemnt}    IN    @{ls_element}
    \    ${id}=    Set Variable If    ${i}<10    0${i}    ${i}
    \    ${id}=    Convert To String    ${id}
    \    ${text}=    Get Text    ${elemnt}
    \    Write File    SaveData\\ChuyenKHoa.csv    "K${id}"    "${text}"
    \    ${i}=    Evaluate    ${i}+1
    
Get List Link Hopital And Place Type For Location
    [Arguments]    ${place_type}
    
    ${ls_tinh_thanh}=    Create List    An Giang    Bà Rịa - Vũng Tàu    Bắc Giang
    :FOR    ${item}    IN    @{ls_tinh_thanh}
    \    Go To    https://vicare.vn/danh-sach/ca-nuoc/
    \    Wait Until Page Contains Element    ${LOAI_CO_SO_BUTTON}
    \    Click Element    ${LOAI_CO_SO_BUTTON}
    \    ${check_box_xpath}=    Replace String    ${LOAI_CO_SO_CHECKBOX}    $$    ${place_type}
    \    Click Element    ${check_box_xpath}
    \    Wait Until Page Contains Element    ${LOC_DANH_SACH_BUTTON}    
    \    Click Element    ${LOC_DANH_SACH_BUTTON}
    \    Wait Until Page Contains Element    ${LIST_COSO_XPATH}
    \    Wait Until Page Contains Element    ${TINH_THANH_BUTTON}
    \    Click Element    ${TINH_THANH_BUTTON}
    \    ${item_xpath}=    Replace String    ${TINH_THANH_CHECKBOX}    $$    ${item}    
    \    Click Element    ${item_xpath}
    \    Click Element    ${LOC_DANH_SACH_BUTTON}
    \    ${have_ls_cs_xpath}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${LIST_COSO_XPATH}
    \    Run Keyword If    ${have_ls_cs_xpath}    Run Get List Link Hopital With Location    ${place_type}

Run Get List Link Hopital With Location
    [Arguments]    ${place_type}
    ${ls_type_ID}=    Read Data File    SaveData\\LoaiDichVu.csv    0
    ${ls_type_NAME}=    Read Data File    SaveData\\LoaiDichVu.csv    1
    ${ls_type_lengh}=    Get Length    ${ls_type_NAME}
    ${uuid}=    Set Variable    Null
    :FOR    ${i}    IN RANGE    0    ${ls_type_lengh}
    \    ${uuid}=    Set Variable If    '@{ls_type_NAME}[${i}]'=='${place_type}'    @{ls_type_ID}[${i}]    ${uuid}
    ${url}=    Get Location
    
    ${have_another_page}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${DICH_VU_NUMBER_PAGE_XPATH}
    ${page_text}=    Run Keyword If    ${have_another_page}    Get Text    ${DICH_VU_NUMBER_PAGE_XPATH}
    ${page_text}=    Run Keyword If    ${have_another_page}    Replace String    ${page_text}    Trang 1 /     ${EMPTY}
    ${page_text}=    Run Keyword If    ${have_another_page}    Convert To Integer    ${page_text}
    ...                        ELSE    Set Variable    1
    
    :FOR    ${i}    IN RANGE    1    ${page_text}+1
    \    Replace And Place Type    ${url}    ${i}    ${uuid}
    \    Run Keyword If    (${i}%100)==0    Clear Memory

Get List Link Hopital And Place Type
    [Arguments]    ${place_type}
    
    ${ls_type_ID}=    Read Data File    SaveData\\LoaiDichVu.csv    0
    ${ls_type_NAME}=    Read Data File    SaveData\\LoaiDichVu.csv    1
    ${ls_type_lengh}=    Get Length    ${ls_type_NAME}
    ${uuid}=    Set Variable    Null
    :FOR    ${i}    IN RANGE    0    ${ls_type_lengh}
    \    ${uuid}=    Set Variable If    '@{ls_type_NAME}[${i}]'=='${place_type}'    @{ls_type_ID}[${i}]    ${uuid}
    
    Go To    https://vicare.vn/danh-sach/ca-nuoc/
    Wait Until Page Contains Element    ${LOAI_CO_SO_BUTTON}
    Click Element    ${LOAI_CO_SO_BUTTON}
    ${check_box_xpath}=    Replace String    ${LOAI_CO_SO_CHECKBOX}    $$    ${place_type}
    Click Element    ${check_box_xpath}
    Wait Until Page Contains Element    ${LOC_DANH_SACH_BUTTON}    
    Click Element    ${LOC_DANH_SACH_BUTTON}
    Wait Until Page Contains Element    ${LIST_COSO_XPATH}
    Wait Until Page Contains Element    ${TINH_THANH_BUTTON}
    Click Element    ${TINH_THANH_BUTTON}
    
    ${ls_tinh_thanh}=    Create List    An Giang    Bà Rịa - Vũng Tàu    Bắc Giang    Bắc Kạn    Bạc Liêu    Bắc Ninh    Bến Tre    Bình Định    Bình Dương    Bình Phước    Bình Thuận    Cà Mau    Cần Thơ    Cao Bằng    Đà Nẵng    Đắk Lắk    Đắk Nông    Điện Biên    Đồng Nai    Đồng Tháp    Gia Lai    Hà Giang    Hà Nam    Hà Nội    Hà Tĩnh    Hải Dương    Hải Phòng    Hậu Giang    Hòa Bình    Hưng Yên    Khánh Hòa    Kiên Giang    Kon Tum    Lai Châu    Lâm Đồng    Lạng Sơn    Lào Cai    Long An    Nam Định    Nghệ An    Ninh Bình    Ninh Thuận    Phú Thọ    Phú Yên    Quảng Bình    Quảng Nam    Quảng Ngãi    Quảng Ninh    Quảng Trị    Sóc Trăng    Sơn La    Tây Ninh    Thái Bình    Thái Nguyên    Thanh Hóa    Thừa Thiên - Huế    Tiền Giang    Trà Vinh    Tuyên Quang    Vĩnh Long    Vĩnh Phúc    Yên Bái
    :FOR    ${item}    IN    @{ls_tinh_thanh}
    \    ${item_xpath}=    Replace String    ${TINH_THANH_CHECKBOX}    $$    ${item}    
    \    Click Element    ${item_xpath}
    
    Click Element    ${LOC_DANH_SACH_BUTTON}
    Wait Until Page Contains Element    ${LIST_COSO_XPATH}
    
    ${url}=    Get Location
    
    Wait Until Page Contains Element    ${DICH_VU_NUMBER_PAGE_XPATH}
    ${page_text}=    Get Text    ${DICH_VU_NUMBER_PAGE_XPATH}
    ${page_text}=    Replace String    ${page_text}    Trang 1 /     ${EMPTY}
    ${page_text}=    Convert To Integer    ${page_text}
    
    :FOR    ${i}    IN RANGE    1    ${page_text}+1
    \    Replace And Place Type    ${url}    ${i}    ${uuid}
    \    Run Keyword If    (${i}%100)==0    Clear Memory

Replace And Place Type
    [Arguments]    ${url}    ${page_number}    ${uuid}
    
    Go To    ${url}?page=${page_number}
    ${ls_element}=    Get WebElements    ${LIST_COSO_XPATH}
    :FOR    ${element}    IN    @{ls_element}
    \    ${name}=    Get Text    ${element}
    \    ${link}=    Get Element Attribute    ${element}    href
    \    Write File    SaveData\\CoSo.csv    "${name}"    "${uuid}"    "${link}"

RUN Get Hopital Datas
    [Arguments]    ${hs_index}    ${dt_key}    ${number_hs_run}
    #Set Log Level    NONE
    Write File    SaveData\\Hopital${dt_key}.csv    "UniqueID"    "Ten Co So Y Te"    "So Dien Thoai"    "Dia Chi"    "Hour"    "Rating"    "Gioi Thieu"    "Dich Vu"    "Bac Si"    "Chuyen Khoa"    "Loai Co So"    "Hinh Anh"
    
    ${ls_hs_NAME}=     Read Data File    SaveData\\CoSo.csv    0
    ${ls_type_ID}=       Read Data File    SaveData\\CoSo.csv    1
    ${ls_hs_LINK}=     Read Data File    SaveData\\CoSo.csv    2
    ${ls_hs_lengh}=    Get Length        ${ls_hs_LINK}
    
    ${LS_CHUYENKHOA_ID}=    Read Data File    SaveData\\ChuyenKHoa.csv    0
    ${LS_CHUYENKHOA_NAME}=    Read Data File    SaveData\\ChuyenKHoa.csv    1
    Set Global Variable    ${LS_CHUYENKHOA_ID}    ${LS_CHUYENKHOA_ID}
    Set Global Variable    ${LS_CHUYENKHOA_NAME}    ${LS_CHUYENKHOA_NAME}
    
    Set Global Variable    ${DOCTOR_UIID}    0
    Set Global Variable    ${HOPITAL_UIID}    ${hs_index}

    :FOR    ${i}    IN RANGE    ${hs_index}    ${hs_index}+${number_hs_run}
    \    Run Keyword And Continue On Failure    Get Hopital Data    @{ls_hs_LINK}[${i}]    @{ls_hs_NAME}[${i}]    @{ls_type_ID}[${i}]    ${dt_key}
    \    Run Keyword If    (${i}%200)==0    Clear Memory
    
Get Hopital Data
    [Arguments]    ${hs_link}    ${hs_name}    ${hs_type_id}    ${dt_key}
    
    Go To    ${hs_link}
    Wait Until Page Contains Element    ${HOPITAL_INFO_XPATH}
    Click Element    ${HOPITAL_INFO_XPATH}
    ${have_more_button}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${HOPITAL_INFO_MORE_BUTTON}    2s
    Sleep    0.3s    
    Run Keyword If    ${have_more_button}    Click Element    ${HOPITAL_INFO_MORE_BUTTON}
    
    ${have_phone}=    Run Keyword And Return Status    Page Should Contain Element    ${PHONE_NUMBER_XPATH}
    ${phone_number}=    Run Keyword If    ${have_phone}    Get Text    ${PHONE_NUMBER_XPATH}    ELSE    Set Variable    ${EMPTY}            
    
    ${have_address}=    Run Keyword And Return Status    Page Should Contain Element    ${HOPITAL_ADDRESS_XPATH}
    ${address}=    Run Keyword If    ${have_address}    Get Text    ${HOPITAL_ADDRESS_XPATH}    ELSE    Set Variable    ${EMPTY} 
    
    ${have_hours}=    Run Keyword And Return Status    Page Should Contain Element    ${HOPITAL_HOUR_XPATH}
    ${hours}=    Run Keyword If    ${have_hours}    Get Text    ${HOPITAL_HOUR_XPATH}    ELSE    Set Variable    ${EMPTY}
    
    ${have_rate}=    Run Keyword And Return Status    Page Should Contain Element    ${HOPITAL_RATING}
    ${rate}=    Run Keyword If    ${have_rate}    Get Text    ${HOPITAL_RATING}    ELSE    Set Variable    ${EMPTY}
    
    ${have_info}=    Run Keyword And Return Status    Page Should Contain Element    ${HOPITAL_INFO_TEXT}
    ${info}=    Run Keyword If    ${have_info}    Get Text    ${HOPITAL_INFO_TEXT}    ELSE    Set Variable    ${EMPTY}
    ${info}=    Replace String    ${info}    "    ${EMPTY}    
	${info}=    Replace String    ${info}    '    ${EMPTY}
    
    ${spec_id}=    Set Variable    ${EMPTY}
    ${ls_chuyen_khoa}=    Get WebElements    ${HOPITAL_SPECIAL_LIST}
    ${i_spec}=    Set Variable    0
    :FOR    ${element}    IN    @{ls_chuyen_khoa}
    \    ${spec}=    Get Text    ${element}
    \    ${id}=    Get Specialist ID    ${spec}
    \    ${spec_id}=    Run Keyword If    '${id}'!='None'    Set Variable If    '${i_spec}'=='0'    ${id}    ${spec_id}, ${id}    ELSE    Set Variable    ${spec_id}
    \    ${i_spec}=    Evaluate    ${i_spec}+1    
    
    ${service}=    Set Variable    ${EMPTY}
    ${ls_dich_vu}=    Get WebElements    ${HOPITAL_SERVICE_LIST}
    ${i_spec}=    Set Variable    0
    :FOR    ${element}    IN    @{ls_dich_vu}
    \    ${ser_name}=    Get Text    ${element}
    \    ${service}=    Set Variable If    '${i_spec}'=='0'    ${ser_name}    ${service}, ${ser_name}
    \    ${i_spec}=    Evaluate    ${i_spec}+1  
    
    ${doctor}=    Set Variable    ${EMPTY}
    ${ls_doctor}=    Get WebElements    ${HOPITAL_DOCTOR_LIST}
    ${i_spec}=    Set Variable    0
    :FOR    ${element}    IN    @{ls_doctor}
    \    ${doctor_name}=    Get Text    ${element}
    \    ${doctor_link}=    Get Element Attribute    ${element}    href
    \    ${id}=         Run Keyword If    ${DOCTOR_UIID}<10    Set Variable    ${dt_key}00000${DOCTOR_UIID}
    \    ...    ELSE    Run Keyword If    ${DOCTOR_UIID}<100    Set Variable    ${dt_key}0000${DOCTOR_UIID}
    \    ...    ELSE    Run Keyword If    ${DOCTOR_UIID}<1000    Set Variable    ${dt_key}000${DOCTOR_UIID}
    \    ...    ELSE    Run Keyword If    ${DOCTOR_UIID}<10000    Set Variable    ${dt_key}00${DOCTOR_UIID}
    \    ...    ELSE    Run Keyword If    ${DOCTOR_UIID}<100000    Set Variable    ${dt_key}0${DOCTOR_UIID}
    \    ...    ELSE    Set Variable      ${dt_key}${DOCTOR_UIID}
    \    ${DOCTOR_UIID}=    Evaluate    ${DOCTOR_UIID}+1
    \    Set Global Variable    ${DOCTOR_UIID}    ${DOCTOR_UIID}
    \    Write File    SaveData\\DoctorLink${dt_key}.csv    "${id}"    "${doctor_name}"    "${doctor_link}"
    \    ${doctor}=    Set Variable If    '${i_spec}'=='0'    ${id}    ${doctor}, ${id}
    \    ${i_spec}=    Evaluate    ${i_spec}+1    
    
    ${hs_id}=      Run Keyword If    ${HOPITAL_UIID}<10    Set Variable    H0000${HOPITAL_UIID}
    ...    ELSE    Run Keyword If    ${HOPITAL_UIID}<100    Set Variable    H000${HOPITAL_UIID}
    ...    ELSE    Run Keyword If    ${HOPITAL_UIID}<1000    Set Variable    H00${HOPITAL_UIID}
    ...    ELSE    Run Keyword If    ${HOPITAL_UIID}<10000    Set Variable    H0${HOPITAL_UIID}
    ...    ELSE    Set Variable      H${HOPITAL_UIID}
    ${HOPITAL_UIID}=    Evaluate    ${HOPITAL_UIID}+1
    Set Global Variable    ${HOPITAL_UIID}    ${HOPITAL_UIID}
    
    ${image_text}=    Get Element Attribute    ${HOPITAL_IMAGE}    style
    ${image_text}=    Replace String    ${image_text}    background-image: url("    ${EMPTY}
    ${image_text}=    Replace String    ${image_text}    ");    ${EMPTY}
    Run Keyword If    '${image_text}'!=''    Download File    ${image_text}    SaveData\\Image\\${hs_id}
    
    ${image_name}=    Set Variable If    '${image_text}'!=''    ${hs_id}.jpg    ${EMPTY}
    
    Write File    SaveData\\Hopital${dt_key}.csv    "${hs_id}"    "${hs_name}"    "${phone_number}"    "${address}"    "${hours}"    "${rate}"    "${info}"    "${service}"    "${doctor}"    "${spec_id}"    "${hs_type_id}"    "${image_name}"
    
Get Specialist ID
    [Arguments]    ${name}
    
    ${count}=    Get Length    ${LS_CHUYENKHOA_NAME}
    :FOR    ${i}    IN RANGE    0    ${count}
    \    Run Keyword If    '${name}'=='@{LS_CHUYENKHOA_NAME}[${i}]'    Return From Keyword    @{LS_CHUYENKHOA_ID}[${i}] 
    
    