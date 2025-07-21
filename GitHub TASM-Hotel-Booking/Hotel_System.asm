; Hotel Booking System in TASM Assembly Language
; ===================================================================

.MODEL SMALL
.STACK 100h

; ===================================================================
; MACROS SECTION
; ===================================================================

; Macro to print a string
PRINT_STRING MACRO string
    MOV AH, 09h         ; DOS function to print string
    LEA DX, string      ; Load effective address of string into DX
    INT 21h             ; Call DOS interrupt
ENDM

; Macro to print a character
PRINT_CHAR MACRO char
    MOV AH, 02h         ; DOS function to print character
    MOV DL, char        ; Character to print
    INT 21h             ; Call DOS interrupt
ENDM

; Macro to print a new line
NEWLINE MACRO
    PRINT_CHAR 0Dh      ; Carriage return
    PRINT_CHAR 0Ah      ; Line feed
ENDM

; Macro to get character input
GET_CHAR MACRO
    MOV AH, 01h         ; DOS function to get character input
    INT 21h             ; Call DOS interrupt (result in AL)
ENDM

; Macro to clear screen
CLEAR_SCREEN MACRO
    MOV AX, 0003h       ; AH=0 (set video mode), AL=3 (text mode 80x25 16 colors)
    INT 10h             ; Call BIOS video interrupt
ENDM

; ===================================================================
; DATA SEGMENT
; ===================================================================
.DATA

; Menu strings
welcome_msg     DB "=== WELCOME TO HOTEL BOOKING SYSTEM ===", "$" 
menu_prompt     DB 0Dh, 0Ah, 0Dh, 0Ah, "Please select an option:", 0Dh, 0Ah, "$" 
option1         DB "1. Book a Room", 0Dh, 0Ah, "$"
option2         DB "2. Cancel a Booking", 0Dh, 0Ah, "$" 
option3         DB "3. View Room Status", 0Dh, 0Ah, "$"
option4         DB "4. Exit", 0Dh, 0Ah, "$"
prompt_choice   DB 0Dh, 0Ah, "Enter your choice (1-4): $"
invalid_msg     DB 0Dh, 0Ah, "Invalid option! Please try again.", 0Dh, 0Ah, "$"
exit_msg        DB 0Dh, 0Ah, "Thank you for using Hotel Booking System! Goodbye.", 0Dh, 0Ah, "$"
prompt_press_key DB "Press any key to continue...$"

; Hotel ASCII Art - Wide building with two doors and windows
hotel_line1     DB "    _______________________________________", 0Dh, 0Ah, "$"
hotel_line2     DB "   |\                                     /|", 0Dh, 0Ah, "$"
hotel_line3     DB "   | \           BADR'S HOTEL            / |", 0Dh, 0Ah, "$"
hotel_line4     DB "   |__\_________________________________/__|", 0Dh, 0Ah, "$"
hotel_line5     DB "   |  |                                 |  |", 0Dh, 0Ah, "$"
hotel_line6     DB "   |  |  [+] [+] [+]       [+] [+] [+]  |  |", 0Dh, 0Ah, "$"
hotel_line7     DB "   |  |  [+] [+] [+]       [+] [+] [+]  |  |", 0Dh, 0Ah, "$"
hotel_line8     DB "   |  |                                 |  |", 0Dh, 0Ah, "$"
hotel_line9     DB "   |  |     _______           _______   |  |", 0Dh, 0Ah, "$"
hotel_line10    DB "   |  |    |       |         |       |  |  |", 0Dh, 0Ah, "$"
hotel_line11    DB "   |  |    |_______|         |_______|  |  |", 0Dh, 0Ah, "$"
hotel_line12    DB "   |  |    |______*|         |______*|  |  |", 0Dh, 0Ah, "$"
hotel_line13    DB "   |__|____|_______|_________|_______|__|__|", 0Dh, 0Ah, "$"

; Room data
MAX_ROOMS       EQU 8                ; 8 rooms total
room_status     DB MAX_ROOMS DUP(0)  ; 0 = vacant, 1 = occupied
room_types      DB 1, 1, 2, 2, 3, 3, 4, 4  ; Pre-assigned room types: 1=Single, 2=Double, 3=Deluxe, 4=Studio
room_prices     DW 100, 150, 200, 300      ; Prices for each room type
room_with_meal  DB MAX_ROOMS DUP(0)  ; 0 = no meal, 1 = with meal
MEAL_PRICE      EQU 50               ; Meal price is 50 RM

; Booking strings
book_header     DB 0Dh, 0Ah, "=== ROOM BOOKING ===", 0Dh, 0Ah, "$"
book_prompt     DB "Select a room type:", 0Dh, 0Ah, "$"
room_type1      DB "1. Single Room (100 RM)", 0Dh, 0Ah, "$"
room_type2      DB "2. Double Room (150 RM)", 0Dh, 0Ah, "$"
room_type3      DB "3. Deluxe Room (200 RM)", 0Dh, 0Ah, "$"
room_type4      DB "4. Studio Room (300 RM)", 0Dh, 0Ah, "$"
room_full       DB "Sorry, all rooms of this type are currently booked.", 0Dh, 0Ah, "$"
meal_prompt     DB "Would you like to add meal option for 50 RM? (Y/N): $"
booking_success DB "Room booked successfully!", 0Dh, 0Ah, "$"
booking_total   DB "Total price: RM $"
booking_details DB "Room details:", 0Dh, 0Ah, "Room Number: $"
meal_included   DB "Meal included: Yes", 0Dh, 0Ah, "$"
meal_excluded   DB "Meal included: No", 0Dh, 0Ah, "$"

; Cancellation strings
cancel_header   DB 0Dh, 0Ah, "=== CANCEL BOOKING ===", 0Dh, 0Ah, "$"
cancel_prompt   DB "Enter room number to cancel (1-8): $"
cancel_success  DB "Room booking canceled successfully!", 0Dh, 0Ah, "$"
cancel_error    DB "This room is not currently booked!", 0Dh, 0Ah, "$"
invalid_room    DB "Invalid room number! Please enter a number between 1 and 8.", 0Dh, 0Ah, "$"

; View status strings 
status_header   DB 0Dh, 0Ah, "=== ROOM STATUS ===", 0Dh, 0Ah, "$"
table_header    DB "Room#| Type      |Price RM |Meal | Status", 0Dh, 0Ah, "$"
table_divider   DB "------------------------------------------", 0Dh, 0Ah, "$"
status_avail    DB "Available$"
status_booked   DB "Booked   $"
meal_yes        DB "Yes $"
meal_no         DB "No  $"
type_single     DB "Single    $"
type_double     DB "Double    $"
type_deluxe     DB "Deluxe    $"
type_studio     DB "Studio    $"

; Fixed table formatting strings
pipe_space3     DB "   | $"
pipe_space      DB " | $"
space5_pipe     DB "     | $"
space4_pipe     DB "    | $"
space3_pipe     DB "   | $"

; Buffer for number conversion
num_buffer      DB 6 DUP(0)

; Variables
current_choice  DB ?                 ; Store user's menu choice
selected_type   DB ?                 ; Store selected room type
selected_room   DB ?                 ; Store selected room number
total_price     DW ?                 ; Store total price
digit_count     DB ?                 ; For number printing
room_counter    DB ?                 ; Counter for room status display

; ===================================================================
; CODE SEGMENT
; ===================================================================
.CODE
MAIN PROC
    ; Initialize data segment
    MOV AX, @data
    MOV DS, AX
    
    ; Main program loop
    main_loop:
        ; Clear the screen and display menu
        CLEAR_SCREEN
        
        ; Display hotel building
        CALL DISPLAY_HOTEL
        
        ; Display welcome message 
        CALL DISPLAY_WELCOME
        
        ; Display menu options
        PRINT_STRING menu_prompt
        PRINT_STRING option1
        PRINT_STRING option2
        PRINT_STRING option3
        PRINT_STRING option4
        
        ; Prompt for choice
        PRINT_STRING prompt_choice
        
        ; Get user input
        GET_CHAR
        SUB AL, '0'              ; Convert ASCII to number (e.g., '1' -> 1)
        MOV current_choice, AL   ; Store the choice
        
        ; Process the user's choice
        CMP current_choice, 1
        JE book_room
        
        CMP current_choice, 2
        JE cancel_booking
        
        CMP current_choice, 3
        JE view_status
        
        CMP current_choice, 4
        JE exit_program
        
        ; If we get here, it's an invalid choice
        PRINT_STRING invalid_msg
        JMP wait_for_key
        
    book_room:
        CALL BOOK_ROOM_PROC
        JMP wait_for_key
        
    cancel_booking:
        CALL CANCEL_BOOKING_PROC
        JMP wait_for_key
        
    view_status:
        CALL VIEW_STATUS_PROC
        JMP wait_for_key
        
    exit_program:
        ; Display exit message and terminate program
        PRINT_STRING exit_msg
        MOV AX, 4C00h               ; DOS function to exit program
        INT 21h
        
    wait_for_key:
        ; Wait for user to press any key before returning to main menu
        NEWLINE
        PRINT_STRING prompt_press_key
        GET_CHAR
        JMP main_loop
        
MAIN ENDP

; ===================================================================
; Display Hotel Procedure
; ===================================================================
DISPLAY_HOTEL PROC
    ; Save registers
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Set cursor position to top of screen
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 2  ; Row 2
    MOV DL, 15 ; Column 15 (for centering)
    INT 10h
    
    ; Display the hotel building line by line
    PRINT_STRING hotel_line1
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 3  ; Row 3
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line2
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 4  ; Row 4
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line3
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 5  ; Row 5
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line4
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 6  ; Row 6
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line5
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 7  ; Row 7
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line6
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 8  ; Row 8
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line7
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 9  ; Row 9
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line8
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 10 ; Row 10
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line9
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 11 ; Row 11
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line10
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 12 ; Row 12
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line11
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 13 ; Row 13
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line12
    
    ; Set cursor for next line
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 14 ; Row 14
    MOV DL, 15 ; Column 15
    INT 10h
    
    PRINT_STRING hotel_line13
    
    ; Move cursor down for menu
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 16 ; Row 16
    MOV DL, 0  ; Column 0
    INT 10h
    
    ; Restore registers
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DISPLAY_HOTEL ENDP

; ===================================================================
; Display Welcome Message with Blinking Cyan Color
; ===================================================================
DISPLAY_WELCOME PROC
    ; Save registers
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    ; Set cursor position for welcome message
    MOV AH, 02h          ; Set cursor position
    MOV BH, 0            ; Page number
    MOV DH, 16           ; Row
    MOV DL, 20           ; Column (center it)
    INT 10h
    
    ; Prepare to print the welcome message
    MOV SI, OFFSET welcome_msg    ; Source string
    MOV BL, 8Bh          ; Attribute: 8Bh = blinking (80h) bright (08h) cyan (03h)
    MOV CX, 1            ; Print one character at a time
    MOV AH, 09h          ; BIOS write character and attribute
    
welcome_loop:
    MOV AL, [SI]         ; Get character
    CMP AL, '$'          ; Check for end of string
    JE welcome_done
    
    INT 10h              ; Display with attribute
    
    ; Move cursor to next position
    INC DL
    MOV AH, 02h
    INT 10h
    
    ; Next character
    INC SI
    MOV AH, 09h          ; Reset AH for next character
    JMP welcome_loop
    
welcome_done:
    ; Newlines after welcome message
    NEWLINE
    
    ; Restore registers
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DISPLAY_WELCOME ENDP

; ===================================================================
; Book Room Procedure
; ===================================================================
BOOK_ROOM_PROC PROC
    ; Display booking header
    CLEAR_SCREEN
    PRINT_STRING book_header
    
    ; Display room type options
    PRINT_STRING book_prompt
    PRINT_STRING room_type1
    PRINT_STRING room_type2
    PRINT_STRING room_type3
    PRINT_STRING room_type4
    PRINT_STRING prompt_choice
    
    ; Get room type choice
    GET_CHAR
    SUB AL, '0'                   ; Convert ASCII to number
    MOV selected_type, AL         ; Store the selected type
    
    ; Validate room type choice (1-4)
    CMP selected_type, 1
    JL invalid_room_type_local    ; Using local jump target
    CMP selected_type, 4
    JG invalid_room_type_local    ; Using local jump target
    JMP validate_room_type_continue
    
invalid_room_type_local:
    PRINT_STRING invalid_msg
    RET
    
validate_room_type_continue:
    ; Find available room of selected type
    MOV CX, MAX_ROOMS             ; Loop counter
    MOV SI, 0                     ; Start with room 0
    
find_room_loop:
    MOV AL, room_types[SI]        ; Get room type
    CMP AL, selected_type         ; Is it the selected type?
    JNE check_next_room           ; If not, check next room
    
    ; Found a room of the right type, check if it's available
    MOV BL, room_status[SI]       ; Get room status
    CMP BL, 0                     ; Is the room vacant?
    JE found_available_room       ; If yes, we found an available room
    
check_next_room:
    INC SI                        ; Move to next room
    LOOP find_room_loop           ; Continue loop
    
    ; If we get here, no rooms of this type are available
    PRINT_STRING room_full
    RET
    
found_available_room:
    ; We found an available room at index SI
    MOV BX, SI                    ; Move SI to BX (16-bit)
    MOV selected_room, BL         ; Then move BL (8-bit) to selected_room
    
    ; Calculate base price based on room type
    MOV BL, selected_type
    DEC BL                        ; Adjust to 0-based index
    MOV BH, 0                     ; Clear BH
    SHL BX, 1                     ; Multiply by 2 for word indexing
    MOV AX, room_prices[BX]       ; Get price for selected type
    MOV total_price, AX           ; Store in total_price
    
    ; Ask if meal option is desired
    NEWLINE
    PRINT_STRING meal_prompt
    
    ; Get meal choice
    GET_CHAR
    
    ; Check if 'Y' or 'y' was selected
    CMP AL, 'Y'
    JE add_meal
    CMP AL, 'y'
    JE add_meal
    
    ; No meal selected
    MOV BX, 0
    MOV BL, selected_room
    MOV room_with_meal[BX], 0     ; Mark as no meal
    JMP show_booking_details
    
add_meal:
    MOV BX, 0
    MOV BL, selected_room
    MOV room_with_meal[BX], 1     ; Mark as with meal
    ADD total_price, MEAL_PRICE   ; Add meal price to total
    
show_booking_details:
    ; Mark room as occupied
    MOV BX, 0
    MOV BL, selected_room
    MOV room_status[BX], 1        ; Set status to occupied
    
    ; Show booking confirmation
    NEWLINE
    PRINT_STRING booking_success
    
    ; Display room number
    PRINT_STRING booking_details
    MOV AL, selected_room
    ADD AL, 1                     ; Convert to 1-based room number
    ADD AL, '0'                   ; Convert to ASCII
    PRINT_CHAR AL
    NEWLINE
    
    ; Display total price
    PRINT_STRING booking_total
    
    ; Convert total price to decimal string and print
    MOV AX, total_price
    CALL PRINT_NUMBER
    NEWLINE
    
    ; Display meal status
    MOV BX, 0
    MOV BL, selected_room
    CMP room_with_meal[BX], 1
    JE with_meal
    
    PRINT_STRING meal_excluded
    JMP booking_complete
    
with_meal:
    PRINT_STRING meal_included
    
booking_complete:
    RET
    
BOOK_ROOM_PROC ENDP

; ===================================================================
; Cancel Booking Procedure
; ===================================================================
CANCEL_BOOKING_PROC PROC
    ; Display cancel header
    CLEAR_SCREEN
    PRINT_STRING cancel_header
    
    ; First display room status to help the user
    CALL VIEW_STATUS_PROC
    
    ; Prompt for room number to cancel
    NEWLINE
    PRINT_STRING cancel_prompt
    
    ; Get room number
    GET_CHAR
    SUB AL, '0'              ; Convert ASCII to number
    
    ; Validate room number (1-8)
    CMP AL, 1
    JL invalid_room_number
    CMP AL, MAX_ROOMS
    JG invalid_room_number
    
    ; Valid room number, convert to 0-based index
    DEC AL
    MOV BL, AL               ; Store room index in BL
    MOV BH, 0                ; Clear BH
    
    ; Check if room is booked
    CMP room_status[BX], 1
    JNE room_not_booked
    
    ; Room is booked, cancel it
    MOV room_status[BX], 0   ; Set status to vacant
    MOV room_with_meal[BX], 0 ; Reset meal option
    
    ; Show cancellation success
    NEWLINE
    PRINT_STRING cancel_success
    JMP cancel_complete
    
invalid_room_number:
    PRINT_STRING invalid_room
    JMP cancel_complete
    
room_not_booked:
    PRINT_STRING cancel_error
    
cancel_complete:
    RET
CANCEL_BOOKING_PROC ENDP

; ===================================================================
; View Room Status Procedure - Split into two procedures to avoid long jumps
; ===================================================================
VIEW_STATUS_PROC PROC
    ; Display status header
    CLEAR_SCREEN
    PRINT_STRING status_header
    
    ; Display table header and improved divider
    PRINT_STRING table_header
    PRINT_STRING table_divider
    
    ; Initialize room counter
    MOV room_counter, 0
    
    ; Process first 4 rooms
    CALL PROCESS_ROOM
    INC room_counter
    CALL PROCESS_ROOM
    INC room_counter
    CALL PROCESS_ROOM
    INC room_counter
    CALL PROCESS_ROOM
    INC room_counter
    
    ; Process last 4 rooms
    CALL PROCESS_ROOM
    INC room_counter
    CALL PROCESS_ROOM
    INC room_counter
    CALL PROCESS_ROOM
    INC room_counter
    CALL PROCESS_ROOM
    
    ; End of table
    PRINT_STRING table_divider
    RET
VIEW_STATUS_PROC ENDP

; Process a single room for display 
PROCESS_ROOM PROC
    ; Get current room index in BX
    MOV BL, room_counter
    MOV BH, 0
    
    ; Display room number with alignment
    MOV DL, BL
    ADD DL, 1               ; Convert to 1-based
    ADD DL, '0'             ; Convert to ASCII
    MOV AH, 02h             ; Function to print character
    INT 21h
    
    ; Fixed spacing before first pipe
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    INT 21h
    INT 21h
    INT 21h
    
    ; Print pipe
    MOV DL, '|'
    INT 21h
    
    ; Fixed spacing after pipe
    MOV DL, ' '
    INT 21h
    
    ; Display room type based on room_types[BX]
    MOV AL, room_types[BX]
    CMP AL, 1
    JE print_single
    CMP AL, 2
    JE print_double
    CMP AL, 3
    JE print_deluxe
    CMP AL, 4
    JE print_studio
    
print_single:
    PRINT_STRING type_single
    JMP print_price
    
print_double:
    PRINT_STRING type_double
    JMP print_price
    
print_deluxe:
    PRINT_STRING type_deluxe
    JMP print_price
    
print_studio:
    PRINT_STRING type_studio
    
print_price:
    ; Print pipe with spacing
    MOV DL, '|'
    MOV AH, 02h
    INT 21h
    
    ; Space after pipe
    MOV DL, ' '
    INT 21h
    
    ; Calculate and display price
    PUSH BX                 ; Save BX
    MOV AL, room_types[BX]
    DEC AL                  ; Adjust to 0-based index
    MOV BL, AL
    MOV BH, 0
    SHL BX, 1               ; Multiply by 2 for word indexing
    MOV AX, room_prices[BX] ; Get base price
    POP BX                  ; Restore BX
    
    ; Check if meal is included
    CMP room_with_meal[BX], 1
    JNE print_base_price
    
    ; Add meal price
    ADD AX, MEAL_PRICE
    
print_base_price:
    ; Print the price
    CALL PRINT_NUMBER
    
    ; Print fixed spacing before next pipe
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    INT 21h
    INT 21h
    INT 21h
    INT 21h
    
    ; Print pipe
    MOV DL, '|'
    INT 21h
    
    ; Space after pipe
    MOV DL, ' '
    INT 21h
    
    ; Display meal status
    CMP room_with_meal[BX], 1
    JE has_meal
    
    PRINT_STRING meal_no
    JMP print_booking_status
    
has_meal:
    PRINT_STRING meal_yes
    
print_booking_status:
    ; Print pipe
    MOV DL, '|'
    MOV AH, 02h
    INT 21h
    
    ; Space after pipe
    MOV DL, ' '
    INT 21h
    
    ; Display booking status
    CMP room_status[BX], 1
    JE is_booked
    
    PRINT_STRING status_avail
    JMP end_room_line
    
is_booked:
    PRINT_STRING status_booked
    
end_room_line:
    ; End of line
    NEWLINE
    RET
PROCESS_ROOM ENDP

; ===================================================================
; PRINT_NUMBER - Prints AX as decimal number
; ===================================================================
PRINT_NUMBER PROC
    ; Save registers
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Check if number is 0
    CMP AX, 0
    JNE not_zero
    
    ; Print 0 directly
    MOV DL, '0'
    MOV AH, 02h
    INT 21h
    JMP print_done
    
not_zero:
    MOV BX, 10          ; Divisor
    MOV CX, 0           ; Digit counter
    
digit_loop:
    MOV DX, 0           ; Clear DX for division
    DIV BX              ; Divide AX by 10, quotient in AX, remainder in DX
    PUSH DX             ; Save remainder (digit) on stack
    INC CX              ; Increment digit count
    CMP AX, 0           ; Check if quotient is 0
    JNE digit_loop      ; If not, continue loop
    
print_loop:
    POP DX              ; Get digit from stack
    ADD DL, '0'         ; Convert to ASCII
    MOV AH, 02h         ; Function to print character
    INT 21h             ; Print it
    LOOP print_loop     ; Repeat for all digits
    
print_done:
    ; Restore registers
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP

END MAIN