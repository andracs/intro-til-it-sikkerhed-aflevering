#!/bin/bash

# Adgangskode Generator Script
# Genererer sikre, tilfældige adgangskoder
# Lavet med Claude, se promptet på  https://claude.ai/public/artifacts/a7ac9a43-02be-40bf-b7c6-eb1e07876793 

# Farver til output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}    Adgangskode Generator       ${NC}"
echo -e "${BLUE}================================${NC}"
echo

# Standard længde
DEFAULT_LENGTH=16

# Tegnsæt til adgangskoder
UPPERCASE="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
LOWERCASE="abcdefghijklmnopqrstuvwxyz"
NUMBERS="0123456789"
SYMBOLS="!@#$%^&*()_+-=[]{}|;:,.<>?"

# Funktion til at generere adgangskode med /dev/urandom
generate_password_urandom() {
    local length=$1
    local charset="$UPPERCASE$LOWERCASE$NUMBERS$SYMBOLS"
    
    # Generér adgangskode
    password=$(tr -dc "$charset" < /dev/urandom | head -c "$length")
    echo "$password"
}

# Funktion til at generere adgangskode med openssl
generate_password_openssl() {
    local length=$1
    
    if command -v openssl &> /dev/null; then
        password=$(openssl rand -base64 32 | tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' | head -c "$length")
        echo "$password"
    else
        echo "openssl ikke tilgængelig"
        return 1
    fi
}

# Funktion til at generere adgangskode med shuf
generate_password_shuf() {
    local length=$1
    local charset="$UPPERCASE$LOWERCASE$NUMBERS$SYMBOLS"
    
    if command -v shuf &> /dev/null; then
        password=$(echo "$charset" | fold -w1 | shuf | head -c "$length" | tr -d '\n')
        echo "$password"
    else
        echo "shuf ikke tilgængelig"
        return 1
    fi
}

# Funktion til at tjekke adgangskodestyrke
check_password_strength() {
    local password=$1
    local score=0
    
    # Tjek længde
    if [[ ${#password} -ge 12 ]]; then
        ((score++))
    fi
    
    # Tjek for store bogstaver
    if [[ "$password" =~ [A-Z] ]]; then
        ((score++))
    fi
    
    # Tjek for små bogstaver
    if [[ "$password" =~ [a-z] ]]; then
        ((score++))
    fi
    
    # Tjek for tal
    if [[ "$password" =~ [0-9] ]]; then
        ((score++))
    fi
    
    # Tjek for specialtegn
    if [[ "$password" =~ [^A-Za-z0-9] ]]; then
        ((score++))
    fi
    
    # Vis styrke
    case $score in
        5)
            echo -e "${GREEN}Meget stærk${NC}"
            ;;
        4)
            echo -e "${GREEN}Stærk${NC}"
            ;;
        3)
            echo -e "${YELLOW}Medium${NC}"
            ;;
        *)
            echo -e "${RED}Svag${NC}"
            ;;
    esac
}

# Funktion til at generere flere adgangskoder
generate_multiple_passwords() {
    local count=$1
    local length=$2
    
    echo -e "${BLUE}Genererer $count adgangskoder på $length tegn:${NC}"
    echo
    
    for ((i=1; i<=count; i++)); do
        password=$(generate_password_urandom "$length")
        echo -e "${GREEN}$i: $password${NC}"
    done
}

# Funktion til at gemme adgangskode
save_password() {
    local password=$1
    local timestamp=$(date "+%Y%m%d_%H%M%S")
    local filename="password_$timestamp.txt"
    
    echo "$password" > "$filename"
    echo -e "${GREEN}Adgangskode gemt i $filename${NC}"
}

# Hovedmenu
while true; do
    echo
    echo -e "${BLUE}Vælg en mulighed:${NC}"
    echo "1) Generér én adgangskode (16 tegn)"
    echo "2) Generér adgangskode med specifik længde"
    echo "3) Generér flere adgangskoder"
    echo "4) Generér kun alfanumerisk adgangskode"
    echo "5) Test forskellige metoder"
    echo "6) Afslut"
    echo
    read -p "Indtast dit valg (1-6): " choice
    
    case $choice in
        1)
            echo
            password=$(generate_password_urandom $DEFAULT_LENGTH)
            echo -e "${GREEN}Genereret adgangskode: $password${NC}"
            echo -n "Styrke: "
            check_password_strength "$password"
            
            read -p "Vil du gemme adgangskoden? (y/n): " save_choice
            [[ "$save_choice" == "y" ]] && save_password "$password"
            ;;
            
        2)
            echo
            read -p "Indtast ønsket længde (8-128): " length
            
            if [[ "$length" -ge 8 ]] && [[ "$length" -le 128 ]]; then
                password=$(generate_password_urandom "$length")
                echo -e "${GREEN}Genereret adgangskode: $password${NC}"
                echo -n "Styrke: "
                check_password_strength "$password"
                
                read -p "Vil du gemme adgangskoden? (y/n): " save_choice
                [[ "$save_choice" == "y" ]] && save_password "$password"
            else
                echo -e "${YELLOW}Længde skal være mellem 8 og 128 tegn${NC}"
            fi
            ;;
            
        3)
            echo
            read -p "Hvor mange adgangskoder? (1-20): " count
            read -p "Længde pr. adgangskode (8-128): " length
            
            if [[ "$count" -ge 1 ]] && [[ "$count" -le 20 ]] && [[ "$length" -ge 8 ]] && [[ "$length" -le 128 ]]; then
                echo
                generate_multiple_passwords "$count" "$length"
            else
                echo -e "${YELLOW}Ugyldige værdier${NC}"
            fi
            ;;
            
        4)
            echo
            read -p "Indtast længde (8-128): " length
            
            if [[ "$length" -ge 8 ]] && [[ "$length" -le 128 ]]; then
                # Kun bogstaver og tal
                charset="$UPPERCASE$LOWERCASE$NUMBERS"
                password=$(tr -dc "$charset" < /dev/urandom | head -c "$length")
                echo -e "${GREEN}Alfanumerisk adgangskode: $password${NC}"
                
                read -p "Vil du gemme adgangskoden? (y/n): " save_choice
                [[ "$save_choice" == "y" ]] && save_password "$password"
            else
                echo -e "${YELLOW}Længde skal være mellem 8 og 128 tegn${NC}"
            fi
            ;;
            
        5)
            echo
            echo -e "${BLUE}Test af forskellige metoder (16 tegn):${NC}"
            echo
            
            echo -n "urandom metode: "
            generate_password_urandom 16
            
            echo -n "openssl metode: "
            generate_password_openssl 16
            
            echo -n "shuf metode: "
            generate_password_shuf 16
            ;;
            
        6)
            echo -e "${GREEN}Farvel!${NC}"
            exit 0
            ;;
            
        *)
            echo -e "${YELLOW}Ugyldigt valg. Prøv igen.${NC}"
            ;;
    esac
done