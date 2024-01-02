# https://yaml.org/spec/1.2.0/


[int] $m = 0
[string] $t = ''

# [string] $yaml_flow = ""

[int] $current_index = 0

$flow = @{}
$document = @{}

# [1] c-printable ::= #x9 | #xA | #xD | [#x20-#x7E]            /* 8 bit */
#                     | #x85 | [#xA0-#xD7FF] | [#xE000-#xFFFD] /* 16 bit */
#                     | [#x10000-#x10FFFF]                     /* 32 bit */ 
function c_printable {
    [char] $char = $yaml_flow[$script:current_index]

    if (($char -eq 0x9) -or
        ($char -eq 0xA) -or
        ($char -eq 0xD) -or
        (($char -ge 0x20) -and ($char -le 0x7E)) -or
        ($char -eq 0x85) -or
        (($char -ge 0xA0) -and ($char -le 0xD7FF)) -or
        (($char -ge 0xE000) -and ($char -le 0xFFFD)) -or
        (($char -ge 0x10000) -and ($char -le 0x10FFFF))) {
            $script:current_index += 1
            return $true
    }
    return $false
}

# [2] nb-json ::= #x9 | [#x20-#x10FFFF]
function nb_json {
    [char] $char = $yaml_flow[$script:current_index]

    if (($char -eq 0x9) -or (($char -ge 0x20) -and ($char -le 0x10FFFF))) {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [3] c-byte-order-mark ::= #xFEFF
function c_byte_order_mark {
    if ($yaml_flow[$script:current_index] -eq 0xFEFF) {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [4] c-sequence-entry ::= “-”
function c_sequence_entry {
    if ($yaml_flow[$current_index] -eq '-') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [5] c-mapping-key ::= “?”
function c_mapping_key {
    if ($yaml_flow[$current_index] -eq '?') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [6] c-mapping-value ::= “:”
function c_mapping_value {
    if ($yaml_flow[$current_index] -eq ':') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [7] c-collect-entry ::= “,”
function c_collect_entry {
    if ($yaml_flow[$current_index] -eq ',') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [8] c-sequence-start ::= “[”
function c_sequence_start {
    if ($yaml_flow[$current_index] -eq '[') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [9] c-sequence-end ::= “]”
function c_sequence_end {
    if ($yaml_flow[$current_index] -eq ']') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [10] c-mapping-start ::= “{”
function c_mapping_start {
    if ($yaml_flow[$current_index] -eq '{') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [11] c-mapping-end ::= “}”
function c_mapping_end {
    if ($yaml_flow[$current_index] -eq '}') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [12] c-comment ::= “#”
function c_comment {
    if ($yaml_flow[$current_index] -eq '#') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [13] c-anchor ::= “&”
function c_anchor {
    if ($yaml_flow[$current_index] -eq '&') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [14] c-alias ::= “*”
function c_alias {
    if ($yaml_flow[$current_index] -eq '*') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [15] c-tag ::= “!”
function c_tag {
    if ($yaml_flow[$current_index] -eq '!') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [16] c-literal ::= “|”
function c_literal {
    if ($yaml_flow[$current_index] -eq '|') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [17] c-folded ::= “>” 
function c_folded {
    if ($yaml_flow[$current_index] -eq '>') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [18] c-single-quote ::= “'”
function c_single_quote {
    if ($yaml_flow[$current_index] -eq "'") {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [19] c-double-quote ::= “"”
function c_double_quote {
    if ($yaml_flow[$current_index] -eq '"') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [20] c-directive ::= “%” 
function c_directive {
    if ($yaml_flow[$current_index] -eq '%') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [21] c-reserved ::= “@” | “`”
function c_reserved {
    if (($yaml_flow[$current_index] -eq '-') -or ($yaml_flow[$current_index] -eq '`')) {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [22] c-indicator ::= “-” | “?” | “:” | “,” | “[” | “]” | “{” | “}”
#                      | “#” | “&” | “*” | “!” | “|” | “>” | “'” | “"”
#                      | “%” | “@” | “`”
function c_indicator {
    if ($yaml_flow[$current_index] -in
        @('-','?',':',',','[',']','{','}','#','&','*','!','|','>',"'",'"','%','@','`')) {
            
        $script:current_index += 1
        return $true
    }
    return $false
}

# [23] c-flow-indicator ::= “,” | “[” | “]” | “{” | “}”
function c_flow_indicator {
    if ($yaml_flow[$current_index] -in @(',','[',']','{','}')) {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [24] b-line-feed ::= #xA    /* LF */
function b_line_feed {
    if ($yaml_flow[$script:current_index] -eq 0xA) {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [25] b-carriage-return ::= #xD    /* CR */
function b_carriage_return {
    if ($yaml_flow[$script:current_index] -eq 0xD) {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [26] b-char ::= b-line-feed | b-carriage-return
function b_char {
    if (b_line_feed) { return $true }
    if (b_carriage_return) { return $true }

    return $false
}

# [27] nb-char ::= c-printable - b-char - c-byte-order-mark
function nb_char {
    [int] $mem_index = $script:current_index

    if (b_char) {
        $script:current_index = $mem_index
        return $false
    }

    if (c_byte_order_mark) {
        $script:current_index = $mem_index
        return $false
    }

    return c_printable
}

# [28] b-break ::= ( b-carriage-return b-line-feed )   /* DOS, Windows */
#                  | b-carriage-return                 /* MacOS upto 9.x */
#                  | b-line-feed                       /* UNIX, MacOS X */ 
function b_break {
    [int] $mem_index = $script:current_index

    [bool] $is_carriage_return = b_carriage_return
    [bool] $is_line_feed       = b_line_feed

    if (-not($is_carriage_return -or $is_line_feed)) {
        $script:current_index = $mem_index
        return $false
    }
    return $true
}

# [29] b-as-line-feed ::= b-break
function b_as_line_feed {
    return b_break
}

# [30] b-non-content ::= b-break
function b_non_content {
    return b_break
}

# [31] s-space ::= #x20 /* SP */ 
function s_space {
    if ($yaml_flow[$script:current_index] -eq 0x20) {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [32] s-tab ::= #x9  /* TAB */ 
function s_tab {
    if ($yaml_flow[$script:current_index] -eq 0x9) {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [33] s-white ::= s-space | s-tab
function s_white {
    [int] $mem_index = $script:current_index

    if (s_space) { return $true }
    if (s_tab) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [34] ns-char ::= nb-char - s-white
function ns_char {
    [int] $mem_index = $script:current_index

    if (s_white) {
        $script:current_index = $mem_index
        return $false 
    }
    if (-not (nb_char)) {
        $script:current_index = $mem_index
        return $false 
    }
    return $true
}

# [35] ns-dec-digit ::= [#x30-#x39] /* 0-9 */ 
function ns_dec_digit {
    if (($yaml_flow[$current_index] -ge 0x30) -and
        ($yaml_flow[$current_index] -le 0x39)) {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [36] ns-hex-digit ::= ns-dec-digit
#                       | [#x41-#x46] /* A-F */ | [#x61-#x66] /* a-f */ 
function ns_hex_digit {
    if (ns_dec_digit) { return $true }

    [char] $char = $yaml_flow[$current_index]

    if ((($char -ge 0x41) -and ($char -le 0x46)) -or 
        (($char -ge 0x61) -and ($char -le 0x66))) {

        $script:current_index += 1
        return $true
    }

    return $false
}

# [37] ns-ascii-letter ::= [#x41-#x5A] /* A-Z */ | [#x61-#x7A] /* a-z */ 
function ns_ascii_letter {
    [char] $char = $yaml_flow[$current_index]

    if ((($char -ge 0x41) -and ($char -le 0x5A)) -or 
        (($char -ge 0x61) -and ($char -le 0x7A))) {

        $script:current_index += 1
        return $true
    }
    return $false
}

# [38] ns-word-char ::= ns-dec-digit | ns-ascii-letter | “-” 
function ns_word_char {
    if (ns_dec_digit) { return $true }
    if (ns_ascii_letter) { return $true }

    if ($yaml_flow[$current_index] -eq '-') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [39] ns-uri-char ::= “%” ns-hex-digit ns-hex-digit | ns-word-char | “#”
#                      | “;” | “/” | “?” | “:” | “@” | “&” | “=” | “+” | “$” | “,”
#                      | “_” | “.” | “!” | “~” | “*” | “'” | “(” | “)” | “[” | “]” 
function ns_uri_char {
    if ($yaml_flow[$current_index] -eq '%') {
        $script:current_index += 1

        return ((ns_hex_digit) -and (ns_hex_digit))
    }

    if (ns_word_char) { return $true }

    if ($yaml_flow[$current_index] -in
        @('#',';','/','?',':','@','&','=','+','$',',','_','.','!','~','*',"'",'(',')','[',']')) {
            
        $script:current_index += 1
        return $true
    }

    return $false
}

# [40] ns-tag-char ::= ns-uri-char - “!” - c-flow-indicator
function ns_tag_char {
    if ($yaml_flow[$current_index] -eq '!') { return $false }

    if (c_flow_indicator) {
        $yaml_flow[$current_index] -= 1
        return $false
    }

    return ns_uri_char
}

# [41] c-escape ::= “\”
function c_escape {
    if ($yaml_flow[$current_index] -eq '\') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [42] ns-esc-null ::= “0”
function ns_esc_null {
    if ($yaml_flow[$current_index] -eq '0') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [43] ns-esc-bell ::= “a”
function ns_esc_bell {
    if ($yaml_flow[$current_index] -eq 'a') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [44] ns-esc-backspace ::= “b” 
function ns_esc_backspace {
    if ($yaml_flow[$current_index] -eq 'b') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [45] ns-esc-horizontal-tab ::= “t” | #x9 
function ns_esc_horizontal_tab {
    if (($yaml_flow[$current_index] -eq 't') -or ($yaml_flow[$current_index] -eq 0x9)) {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [46] ns-esc-line-feed ::= “n”
function ns_esc_line_feed {
    if ($yaml_flow[$current_index] -eq 'n') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [47] ns-esc-vertical-tab ::= “v”
function ns_esc_vertical_tab {
    if ($yaml_flow[$current_index] -eq 'v') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [48] ns-esc-form-feed ::= “f” 
function ns_esc_form_feed {
    if ($yaml_flow[$current_index] -eq 'f') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [49] ns-esc-carriage-return ::= “r”
function ns_esc_carriage_return {
    if ($yaml_flow[$current_index] -eq 'r') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [50] ns-esc-escape ::= “e” 
function ns_esc_escape {
    if ($yaml_flow[$current_index] -eq 'e') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [51] ns-esc-space ::= #x20 
function ns_esc_space {
    if ($yaml_flow[$current_index] -eq 'b') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [52] ns-esc-double-quote ::= “"”
function ns_esc_double_quote {
    if ($yaml_flow[$current_index] -eq '"') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [53] ns-esc-slash ::= “/” 
function ns_esc_slash {
    if ($yaml_flow[$current_index] -eq '/') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [54] ns-esc-backslash ::= “\”
function ns_esc_backslash {
    if ($yaml_flow[$current_index] -eq '\') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [55] ns-esc-next-line ::= “N” 
function ns_esc_next_line {
    if ($yaml_flow[$current_index] -eq 'b') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [56] ns-esc-non-breaking-space ::= “_” 
function ns_esc_non_breaking_space {
    if ($yaml_flow[$current_index] -eq '_') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [57] ns-esc-line-separator ::= “L” 
function ns_esc_line_separator {
    if ($yaml_flow[$current_index] -eq 'L') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [58] ns-esc-paragraph-separator ::= “P” 
function ns_esc_paragraph_separator {
    if ($yaml_flow[$current_index] -eq 'P') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [59] ns-esc-8-bit ::= “x” ( ns-hex-digit × 2 ) 
function ns_esc_8_bit {
    [int] $mem_index = $current_index

    if ($yaml_flow[$current_index] -eq 'x') {
        $script:current_index += 1

        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        return $true
    }
    $script:current_index = $mem_index
    return $false
}

# [60] ns-esc-16-bit ::= “u” ( ns-hex-digit × 4 ) 
function ns_esc_16_bit {
    [int] $mem_index = $current_index

    if ($yaml_flow[$current_index] -eq 'u') {
        $script:current_index += 1

        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }

        return $true
    }
    $script:current_index = $mem_index
    return $false
}

# [61] ns-esc-32-bit ::= “U” ( ns-hex-digit × 8 ) 
function ns_esc_32_bit {
    [int] $mem_index = $current_index

    if ($yaml_flow[$current_index] -eq 'U') {
        $script:current_index += 1

        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }
        if (-not (ns_hex_digit)) {
            $script:current_index = $mem_index
            return $false
        }

        return $true
    }
    $script:current_index = $mem_index
    return $false
}

# [62] c-ns-esc-char ::= “\”
#                        ( ns-esc-null | ns-esc-bell | ns-esc-backspace
#                        | ns-esc-horizontal-tab | ns-esc-line-feed
#                        | ns-esc-vertical-tab | ns-esc-form-feed
#                        | ns-esc-carriage-return | ns-esc-escape | ns-esc-space
#                        | ns-esc-double-quote | ns-esc-slash | ns-esc-backslash
#                        | ns-esc-next-line | ns-esc-non-breaking-space
#                        | ns-esc-line-separator | ns-esc-paragraph-separator
#                        | ns-esc-8-bit | ns-esc-16-bit | ns-esc-32-bit )
function c_ns_esc_char([string] $word) {
    [int] $mem_index = $current_index

    if ($yaml_flow[$current_index] -eq '\') {
        if (ns_esc_null) { return $true }
        if (ns_esc_bell) { return $true }
        if (ns_esc_backspace) { return $true }
        if (ns_esc_horizontal_tab) { return $true }
        if (ns_esc_line_feed) { return $true }
        if (ns_esc_vertical_tab) { return $true }
        if (ns_esc_form_feed) { return $true }
        if (ns_esc_carriage_return) { return $true }
        if (ns_esc_escape) { return $true }
        if (ns_esc_space) { return $true }
        if (ns_esc_double_quote) { return $true }
        if (ns_esc_slash) { return $true }
        if (ns_esc_backslash) { return $true }
        if (ns_esc_next_line) { return $true }
        if (ns_esc_non_breaking_sp) { return $true }
        if (ns_esc_line_separator) { return $true }
        if (ns_esc_paragraph_separator) { return $true }
        if (ns_esc_8_bit) { return $true }
        if (ns_esc_16_bit) { return $true }
        if (ns_esc_32_bit) { return $true }
    }
    $script:current_index = $mem_index
    return $false
}

# [63] s-indent(n) ::= s-space × n
function s_indent([int] $n) {
    [int] $mem_index = $current_index

    foreach ($i in 0..$n) {
        if (-not (s_space)) {
            $script:current_index = $mem_index
            return $false
        }
    }
    $script:m = $n
    return $true
}

# [64] s-indent(<n) ::= s-space × m /* Where m < n */
function s_indent_lt([int] $n) {
    [int] $mem_index = $current_index
    [int] $indent = 0

    while (s_space) { $indent += 1 }

    if ($indent -lt $n) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [65] s-indent(≤n) ::= s-space × m /* Where m ≤ n */
function s_indent_le([int] $n) {
    [int] $mem_index = $current_index
    [int] $indent = 0

    while (s_space) { $indent += 1 }

    if ($indent -le $n) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [66] s-separate-in-line ::= s-white+ | /* Start of line */
function s_separate_in_line {
    [int] $mem_index = $current_index

    $script:current_index -= 1
    [int] $separate       = 0

    if (b_break) { $separate = += 1 }
    else { $script:current_index += 1 }

    while (s_white) {
        $separate += 1
    }

    if ($separate -gt 0) {
        return $true
    }

    $script:current_index = $mem_index
    return $false
}

# [67] s-line-prefix(n,c) ::= c = block-out ⇒ s-block-line-prefix(n)
#                             c = block-in  ⇒ s-block-line-prefix(n)
#                             c = flow-out  ⇒ s-flow-line-prefix(n)
#                             c = flow-in   ⇒ s-flow-line-prefix(n)
function s_line_prefix([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if ($context -in @('block-out', 'block-in')) {
        return s_block_line_prefix($n)
    } 
    if ($context -in @('flow-in', 'flow-out')) {
        return s_flow_line_prefix($n)
    }

    $script:current_index = $mem_index
    return $false
}

# [68] s-block-line-prefix(n) ::= s-indent(n)
function s_block_line_prefix([int] $n) {
    [int] $mem_index = $script:current_index

    if (s_indent($n)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [69] s-flow-line-prefix(n) ::= s-indent(n) s-separate-in-line? 
function s_flow_line_prefix([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (s_indent($n))) {
        $script:current_index = $mem_index
        return $false
    }
    if (s_separate_in_line) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [70] l-empty(n,c) ::= ( s-line-prefix(n,c) | s-indent(<n) )
#                        b-as-line-feed
function l_empty([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index
    
    [bool] $result = s_line_prefix($n, $context)

    if (-not $result) { $result = s_indent_le($n) }

    if (b_as_line_feed) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [71] b-l-trimmed(n,c) ::= b-non-content l-empty(n,c)+ 
function b_l_trimmed([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (b_non_content)) {
        $script:current_index = $mem_index
        return $false
    }
    if (l_empty($n, $context)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [72] b-as-space ::= b-break
function b_as_space {
    [int] $mem_index = $script:current_index

    if (b_break) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [73] b-l-folded(n,c) ::= b-l-trimmed(n,c) | b-as-space
function b_l_folded([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (b_l_trimmed($n, $context)) { return $true }
    if (b_as_space) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [74] s-flow-folded(n) ::= s-separate-in-line? b-l-folded(n,flow-in)
#                           s-flow-line-prefix(n)
function s_flow_folded([int] $n) {
    [int] $mem_index = $script:current_index

    s_separate_in_line

    if ((b_l_folded($n, 'flow-in')) -and (s_flow_line_prefix($n))) {
        return $true
    }

    $script:current_index = $mem_index
    return $false
}

# [75] c-nb-comment-text ::= “#” nb-char*
function c_nb_comment_text {
    [int] $mem_index = $script:current_index

    if ($yaml_flow[$script:current_index] -eq '#') {
        $script:current_index += 1 # increase the index because it the '#' character
        [string] $comment = '#'

        while (nb_char) {
            $comment += $yaml_flow[$script:current_index-1]
        }
        
        $script:current_index -= 1 # decrease the index because of the line break
        Write-Host "$comment"

        return $true
    }
    $script:current_index = $mem_index
    return $false
}

# [76] b-comment ::= b-non-content | /* End of file */
function b_comment {
    [int] $mem_index = $script:current_index

    if ((b_non_content) -or ($script:current_index -eq $yaml_flow.Length)) {
        return $true
    }

    $script:current_index = $mem_index
    return $false
}

# [77] s-b-comment ::= ( s-separate-in-line c-nb-comment-text? )?
#                      b-comment
function s_b_comment {
    [int] $mem_index = $script:current_index

    s_separate_in_line
    c_nb_comment_text

    if (b_comment) { return $true }
    
    $script:current_index = $mem_index
    return $false
}

# [78] l-comment ::= s-separate-in-line c-nb-comment-text? b-comment
function l_comment {
    [int] $mem_index = $script:current_index

    [bool] $is_separate_in_line = s_separate_in_line
    [bool] $is_comment_text     = c_nb_comment_text
    [bool] $is_comment          = b_comment

    if ($is_separate_in_line -and ($is_comment_text -and $true) -and $is_comment) {
        return $true
    }

    $script:current_index = $mem_index
    return $false
}

# [79] s-l-comments ::= ( s-b-comment | /* Start of line */ )
#                        l-comment*
function s_l_comments {
    [int] $mem_index = $script:current_index

    $script:current_index -= 1
    [int] $result          = 0

    if (-not (b_break)) {
        $script:current_index += 1

        if (-not (s_b_comment)) { return $false }
    }

    while (l_comment) { 
        $result += 1
        b_break
    }
    if ($result -ge 0) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [80] s-separate(n,c) ::= c = block-out ⇒ s-separate-lines(n)
#                          c = block-in  ⇒ s-separate-lines(n)
#                          c = flow-out  ⇒ s-separate-lines(n)
#                          c = flow-in   ⇒ s-separate-lines(n)
#                          c = block-key ⇒ s-separate-in-line
#                          c = flow-key  ⇒ s-separate-in-line
function s_separate([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if ($context -in @('block-out','block-in','flow-out','flow-in')) {
        if (s_separate_in_lines($n)) { return $true }
    }

    if ($context -in @('block-key','flow-key')) {
        if (s_separate_in_line) { return $true }
    }

    $script:current_index = $mem_index
    return $false
}

# 81] s-separate-lines(n) ::= ( s-l-comments s-flow-line-prefix(n) )
#                              | s-separate-in-line
function s_separate_in_lines([int] $n) {
    [int] $mem_index = $script:current_index

    if (s_separate_in_line) { return $true }

    if ((s_l_comments) -and (s_flow_line_prefix($n))) {
        return $true
    }

    $script:current_index = $mem_index
    return $false
}

# [82] l-directive ::= “%”
#                      ( ns-yaml-directive
#                      | ns-tag-directive
#                      | ns-reserved-directive )
#                      s-l-comments
function l_directive {
    [int] $mem_index = $script:current_index

    if ($yaml_flow[$current_index] -ne '%') { return $false }

    if ((ns_yaml_directive) -or
        (ns_tag_directive) -or
        (ns_reserved_directive)) {

        if (s_l_comments) { return $true }
    }

    $script:current_index = $mem_index
    return $false
}

# [83] ns-reserved-directive ::= ns-directive-name
#                                ( s-separate-in-line ns-directive-parameter )*
function ns_reserved_directive {
    [int] $mem_index = $script:current_index

    if (-not (ns_directive_name)) { return $false }

    [int] $result = 0

    while ((s_separate_in_line) -and
           (ns_directive_parameter)) {
        
        $result += 1
    }
    if ($result -ge 0) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [84] ns-directive-name ::= ns-char+
function ns_directive_name {
    [int] $mem_index = $script:current_index
    [int] $result    = 0

    while (ns_char) { $result += 1 }

    if ($result -gt 0) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [85] ns-directive-parameter ::= ns-char+
function ns_directive_parameter {
    [int] $mem_index = $script:current_index
    [int] $result    = 0

    while (ns_char) { $result += 1 }
    
    if ($result -gt 0) { return $true }
    $script:current_index = $mem_index
}

# [86] ns-yaml-directive ::= “Y” “A” “M” “L”
#                            s-separate-in-line ns-yaml-version
function ns_yaml_directive {
    [int] $mem_index = $script:current_index

    if ($yaml_flow[$current_index] -ne 'Y') { return $false }
    else { $script:current_index += 1 }

    if ($yaml_flow[$current_index] -ne 'A') {
        $script:current_index = $mem_index
        return $false
    } else { $script:current_index += 1 }

    if ($yaml_flow[$current_index] -ne 'M') {
        $script:current_index = $mem_index
        return $false
    } else { $script:current_index += 1 }

    if ($yaml_flow[$current_index] -ne 'L') {
        $script:current_index = $mem_index
        return $false
    } else { $script:current_index += 1 }
    
    if (-not (s_separate_in_line)) {
        $script:current_index = $mem_index
        return $false
    }

    if (ns_yaml_version) { return $true }
    $script:current_index = $mem_index
    return $false
}

# [87] ns-yaml-version ::= ns-dec-digit+ “.” ns-dec-digit+
function ns_yaml_version {
    [int] $mem_index = $script:current_index
    [int] $major     = 0

    while ($yaml_flow[$current_index] -match "\d") {
        $major += 1
        $script:current_index += 1
    }

    if ($major -and ($yaml_flow[$current_index] -eq '.')) {
        $script:current_index += 1
    } else {
        $script:current_index = $mem_index
        return $false
    }

    [int] $minor = 0

    while ($yaml_flow[$current_index] -match "\d") {
        $minor += 1
        $script:current_index += 1
    }

    if ($minor -gt 0) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [88] ns-tag-directive ::= “T” “A” “G”
#                           s-separate-in-line c-tag-handle
#                           s-separate-in-line ns-tag-prefix
function ns_tag_directive {
    [int] $mem_index = $script:current_index
    
    if ($yaml_flow[$current_index] -ne 'T') { return $false }
    $script:current_index += 1

    if ($yaml_flow[$current_index] -ne 'A') {
        $script:current_index = $mem_index
        return $false
    }
    $script:current_index += 1

    if ($yaml_flow[$current_index] -ne 'G') {
        $script:current_index = $mem_index
        return $false
    }
    $script:current_index += 1

    if (-not (s_separate_in_line)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (c_tag_handle)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (s_separate_in_line)) {
        $script:current_index = $mem_index
        return $false
    }
    
    if (ns_tag_prefix) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [89] c-tag-handle ::= c-named-tag-handle
#                       | c-secondary-tag-handle
#                       | c-primary-tag-handle
function c_tag_handle {
    [int] $mem_index = $script:current_index

    if (c_named_tag_handle) { return $true }
    if (c_secondary_tag_handle) { return $true }
    if (c_primary_tag_handle) { return $true }

    $script:current_index = $mem_index
}

# [90] c-primary-tag-handle ::= “!”
function c_primary_tag_handle {
    if ($yaml_flow[$current_index] -ne '!') { return $false }
    $script:current_index += 1

    return $true
}

# [91] c-secondary-tag-handle ::= “!” “!”
function c_secondary_tag_handle {
    if ($yaml_flow[$current_index] -ne '!') { return $false }
    $script:current_index += 1

    if ($yaml_flow[$current_index] -ne '!') {
        $script:current_index -= 1
        return $false
    }
    $script:current_index += 1

    return $true
}

# [92] c-named-tag-handle ::= “!” ns-word-char+ “!”
function c_named_tag_handle {
    [int] $mem_index = $script:current_index

    if ($yaml_flow[$current_index] -ne '!') { return $false }
    $script:current_index += 1

    [int] $word_char = 0

    while (ns_word_char) { $word_char += 1 }

    if ($yaml_flow[$current_index] -ne '!') {
        $script:current_index = $mem_index
        return $false
    }

    $script:current_index += 1
    
    if ($word_char -gt 0) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [93] ns-tag-prefix ::= c-ns-local-tag-prefix | ns-global-tag-prefix
function ns_tag_prefix {
    [int] $mem_index = $script:current_index

    if (c_ns_local_tag_prefix) { return $true }
    if (ns_global_tag_prefix) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [94] c-ns-local-tag-prefix ::= “!” ns-uri-char*
function c_ns_local_tag_prefix {
    [int] $mem_index = $script:current_index

    if ($yaml_flow[$current_index] -ne '!') { return $false }
    $script:current_index += 1

    [int] $char_uri = 0

    while (ns_uri_char) { $har_uri += 1 }

    if ($char_uri -ge 0) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [95] ns-global-tag-prefix ::= ns-tag-char ns-uri-char*
function ns_global_tag_prefix {
    [int] $mem_index = $script:current_index

    if (-not (ns_tag_char)) {
        $script:current_index = $mem_index
        return $false
    }

    [int] $char_uri = 0
    while (ns_uri_char) { $char_uri += 1 }

    if ($char_uri -ge 0) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [96] c-ns-properties(n,c) ::= ( c-ns-tag-property
#                               ( s-separate(n,c) c-ns-anchor-property )? )
#                               | ( c-ns-anchor-property
#                               ( s-separate(n,c) c-ns-tag-property )? )
function c_ns_properties([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (c_ns_tag_property) {
        $mem_index = $script:current_index

        if (-not ((s_separate($n, $context)) -and (c_ns_anchor_property))) {
            $script:current_index = $mem_index
        }
        return $true
    }

    if (c_ns_anchor_property) {
        $mem_index = $script:current_index

        if (-not ((s_separate($n, $context)) -and (c_ns_tag_property))) {
            $script:current_index = $mem_index
        }
        return $true
    }
    $script:current_index = $mem_index
    return $false
}

# [97] c-ns-tag-property ::= c-verbatim-tag
#                            | c-ns-shorthand-tag
#                            | c-non-specific-tag
function c_ns_tag_property {
    [int] $mem_index = $script:current_index

    if (c_verbatim_tag) { return $true }

    if (c_ns_shorthand_tag) { return $true }

    if (c_non_specific_tag) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [98] c-verbatim-tag ::= “!” “<” ns-uri-char+ “>”
function c_verbatim_tag {
    [int] $mem_index = $script:current_index

    if (-not ($yaml_flow[$current_index] -eq '!')) { return $false }
    $script:current_index += 1

    if (-not ($yaml_flow[$current_index] -eq '<')) {
        $script:current_index = $mem_index
        return $false
    }

    $script:current_index += 1
    [int] $char_uri = 0

    while (ns_uri_char) { $char_uri += 1 }
    if ($char_uri -eq 0) {
        $script:current_index = $mem_index
        return $false
    }

    if ($yaml_flow[$current_index] -eq '>') {
        $script:current_index += 1
        return $true
    }

    $script:current_index = $mem_index
    return $false
}

# [99] c-ns-shorthand-tag ::= c-tag-handle ns-tag-char+
function c_ns_shorthand_tag {
    [int] $mem_index = $script:current_index

    if (-not (c_tag_handle)) {
        $script:current_index = $mem_index
        return $false
    }

    [int] $tag_char = 0
    while (ns_tag_char) { $tag_char += 1 }

    if ($tag_char -eq 0) {
        $script:current_index = $mem_index
        return $false
    }
    return $true
}

# [100] c-non-specific-tag ::= “!”
function c_non_specific_tag {
    if ($yaml_flow[$current_index] -eq '!') {
        $script:current_index += 1
        return $true
    }
    return $false
}

# [101] c-ns-anchor-property ::= “&” ns-anchor-name
function c_ns_anchor_property {
    [int] $mem_index = $script:current_index

    if (-not ($yaml_flow[$current_index] -eq '&')) { return $false }
    $script:current_index += 1

    if (-not (ns_anchor_name)) {
        $script:current_index = $mem_index
        return $false
    }
    return $true
}

# [102] ns-anchor-char ::= ns-char - c-flow-indicator
function ns_anchor_char {
    [int] $mem_index = $script:current_index

    if (c_flow_indicator) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (ns_char)) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [103] ns-anchor-name ::= ns-anchor-char+
function ns_anchor_name {
    [int] $mem_index = $script:current_index
    [int] $anchor_char = 0

    while (ns_anchor_char) {
        $anchor_char += 1
    }

    if ($anchor_char -eq 0) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [104] c-ns-alias-node ::= “*” ns-anchor-name
function c_ns_alias_node {
    if ($yaml_flow[$current_index] -ne '*') { return $false }
    $script:current_index += 1
    
    [int] $mem_index = $script:current_index

    if (-not (ns_anchor_name)) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [105] e-scalar ::= /* Empty */
function e_scalar {
    return $true
}

# [106] e-node ::= e-scalar
function e_node {
    return e_scalar
}

# [107] nb-double-char ::= c-ns-esc-char | ( nb-json - “\” - “"” )
function nb_double_char {
    [int] $mem_index = $script:current_index

    if (c_ns_esc_char) { return $true }
    if ($yaml_flow[$current_index] -in @('\', '"')) { return $false }

    if (nb_json) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [108] ns-double-char ::= nb-double-char - s-white
function ns_double_char {
    [int] $mem_index = $script:current_index

    if (s_white) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (nb_double_char)) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [109] c-double-quoted(n,c) ::= “"” nb-double-text(n,c) “"”
function c_double_quoted([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if ($yaml_flow[$current_index] -ne '"') { return $false }
    $script:current_index += 1

    if (-not(nb_double_text($n, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    if ($yaml_flow[$current_index] -ne '"') {
        $script:current_index = $mem_index
        return $false
    }

    $script:current_index += 1
    return $true
}

# [110] nb-double-text(n,c) ::= c = flow-out  ⇒ nb-double-multi-line(n)
#                               c = flow-in   ⇒ nb-double-multi-line(n)
#                               c = block-key ⇒ nb-double-one-line
#                               c = flow-key  ⇒ nb-double-one-line
function nb_double_text([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if ($context -in @('flow-out', 'flow-in')) {
        if (-not (nb_double_multi_line($n))) {
            $script:current_index = $mem_index
            return $false
        }

        return $true
    }

    if ($context -in @('block-key', 'flow-key')) {
        if (-not (nb_double_one_line($n))) {
            $script:current_index = $mem_index
            return $false
        }

        return $true
    }

    return $false
}

# [111] nb-double-one-line ::= nb-double-char*
function nb_double_one_line {
    while (nb_double_char) { }

    return $true
}

# [112] s-double-escaped(n) ::= s-white* “\” b-non-content
#                               l-empty(n,flow-in)* s-flow-line-prefix(n)
function s_double_escaped([int] $n) {
    [int] $mem_index = $script:current_index

    while (s_white) {}

    if ($yaml_flow[$current_index] -ne '\') {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (b_non_content)) {
        $script:current_index = $mem_index
        return $false
    }

    while (l_empty($n, 'flow-in')) {}

    if (-not (s_flow_line_prefix($n))) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [113] s-double-break(n) ::= s-double-escaped(n) | s-flow-folded(n)
function s_double_break([int] $n) {
    [int] $mem_index = $script:current_index

    if (s_double_escaped($n)) { return $true }
    $script:current_index = $mem_index

    if (s_flow_folded($n)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [114] nb-ns-double-in-line ::= ( s-white* ns-double-char )*
function nb_ns_double_in_line {
    while ($true) {
        while (s_white) {}

        if (-not (ns_double_char)) { return $true }
    }
}

# [115] s-double-next-line(n) ::= s-double-break(n)
#                                 ( ns-double-char nb-ns-double-in-line
#                                 ( s-double-next-line(n) | s-white* ) )?
function s_double_next_line([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (s_double_break($n))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (ns_double_char)) {
        $script:current_index = $mem_index
        return $true
    }

    if (-not (nb_ns_double_in_line)) {
        $script:current_index = $mem_index
        return $true
    }

    if (s_double_next_line($n)) {
        return $true
    }

    while (s_white) {}
    return $true
}

# [116] nb-double-multi-line(n) ::= nb-ns-double-in-line
#                                   ( s-double-next-line(n) | s-white* )
function nb_double_multi_line([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (nb_ns_double_in_line)) {
        $script:current_index = $mem_index
        return $false
    }

    if (s_double_next_line($n)) { return $true }
    while (s_white) {}

    return $true
}

# [117] c-quoted-quote ::= “'” “'”
function c_quoted_quote {
    if (-not ($yaml_flow[$current_index] -eq "'")) {
        return $false
    }

    $script:current_index += 1

    if (-not ($yaml_flow[$current_index] -eq "'")) {
        $script:current_index = 1
        return $false
    }

    $script:current_index += 1
    return $true
}

# [118] nb-single-char ::= c-quoted-quote | ( nb-json - “'” )
function nb_single_char {
    [int] $mem_index = $script:current_index

    if (c_quoted_quote) { return $true }

    if ($yaml_flow[$current_index] -eq "'") {
        $script:current_index = $mem_index
        return $false
    }

    if (nb_json) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [119] ns-single-char ::= nb-single-char - s-white
function ns_single_char {
    [int] $mem_index = $script:current_index

    if (s_white) {
        $script:current_index = $mem_index
        return $false
    }

    if (nb_single_char) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [120] c-single-quoted(n,c) ::= “'” nb-single-text(n,c) “'”
function c_single_quoted([int] $n, [string] $context) {
    if ($yaml_flow[$current_index] -ne "'") {
        return $false
    }

    $script:current_index += 1
    [int] $mem_index = $script:current_index

    if (-not(nb_single_text($n, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    if ($yaml_flow[$current_index] -ne "'") {
        $script:current_index = $mem_index
        return $false
    }

    $script:current_index += 1
    return $true
}

# [121] nb-single-text(n,c) ::= c = flow-out  ⇒ nb-single-multi-line(n)
#                               c = flow-in   ⇒ nb-single-multi-line(n)
#                               c = block-key ⇒ nb-single-one-line
#                               c = flow-key  ⇒ nb-single-one-line
function nb_single_text([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if ($context -in @('flow-out', 'flow-in')) {
        if (-not(nb_single_multi_line($n))) {
            $script:current_index = $mem_index
            return $false
        }
        return $true
    }

    if ($context -in @('block-key', 'flow-key')) {
        if (-not(nb_single_one_line)) {
            $script:current_index = $mem_index
            return $false
        }
        return $true
    }

    return $false
}

# [122] nb-single-one-line ::= nb-single-char*
function nb_single_one_line {
    while (nb_single_char) {}

    return $true
}

# [123] nb-ns-single-in-line ::= ( s-white* ns-single-char )*
function nb_ns_single_in_line {
    while ($true) {
        while (s_white) {}

        if (-not (ns_single_char)) { return $true }
    }
}

# [124] s-single-next-line(n) ::= s-flow-folded(n)
#                                 ( ns-single-char nb-ns-single-in-line
#                                 ( s-single-next-line(n) | s-white* ) )?
function s_single_next_line([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (s_flow_folded($n))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (ns_single_char)) {
        $script:current_index = $mem_index
        return $true
    }

    if (-not (nb_ns_single_in_line)) {
        $script:current_index = $mem_index
        return $true
    }

    if (s_single_next_line($n)) {
        return $true
    }

    while (s_white) { }

    return $true
}

# [125] nb-single-multi-line(n) ::= nb-ns-single-in-line
#                                   ( s-single-next-line(n) | s-white* )
function nb_single_multi_line([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (nb_ns_single_in_line)) {
        $script:current_index = $mem_index
        return $false
    }

    if (s_single_next_line($n)) {
        return $true
    }

    while (s_white) {}
    return $true
}

# [126] ns-plain-first(c) ::= ( ns-char - c-indicator )
#                             | ( ( “?” | “:” | “-” ) /* Followed by an ns-char */ )
function ns_plain_first([string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (c_indicator)) {
        if (ns_char) {
            return $true
        }
    }

    $script:current_index = $mem_index

    if ($yaml_flow[$current_index] -in @('?',':','-')) {
        $script:current_index += 1
        if (ns_char) { return $true }
    }

    $script:current_index = $mem_index
    return $false
}

# [127] ns-plain-safe(c) ::= c = flow-out  ⇒ ns-plain-safe-out
#                            c = flow-in   ⇒ ns-plain-safe-in
#                            c = block-key ⇒ ns-plain-safe-out
#                            c = flow-key  ⇒ ns-plain-safe-in
function ns_plain_safe([string] $context) {
    [int] $mem_index = $script:current_index

    if ($context -in @('flow-out', 'block-key')) {
        if (-not (ns_plain_safe_out)) {
            $script:current_index = $mem_index
            return $false
        }

        return $true
    }

    if ($context -in @('flow-in', 'flow-key')) {
        if (-not (ns_plain_safe_in)) {
            $script:current_index = $mem_index
            return $false
        }

        return $true
    }

    $script:current_index = $mem_index
    return $false
}

# [128] ns-plain-safe-out ::= ns-char - “:” - “#”
function ns_plain_safe_out {
    [int] $mem_index = $script:current_index

    if ($yaml_flow[$current_index] -in @(':', '#')) {
        return $false
    }

    $script:current_index += 1

    if (-not (ns_char)) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [129] ns-plain-safe-in ::= ns-plain-safe-out - c-flow-indicator
function ns_plain_safe_in {
    [int] $mem_index = $script:current_index

    if (c_flow_indicator) {
        $script:current_index = $mem_index
        return $false
    }

    if (ns_plain_safe_out) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [130] ns-plain-char(c) ::= ns-plain-safe(c)
#                            | ( /* An ns-char preceding */ “#” )
#                            | ( “:” /* Followed by an ns-char */ )
function ns_plain_char([string] $context) {
    [int] $mem_index = $script:current_index

    if (ns_plain_safe($context)) { return $true }

    $script:current_index = $mem_index

    if (ns_char) {
        if ($yaml_flow[$current_index] -eq '#') {
            $script:current_index += 1
            return $true
        }
    }

    $script:current_index = $mem_index

    if ($yaml_flow[$current_index] -eq ':') {
        $script:current_index += 1
        if (ns_char) { return $true }
    }

    $script:current_index = $mem_index
    return $false
}

# [131] ns-plain(n,c) ::= c = flow-out  ⇒ ns-plain-multi-line(n,c)
#                         c = flow-in   ⇒ ns-plain-multi-line(n,c)
#                         c = block-key ⇒ ns-plain-one-line(c)
#                         c = flow-key  ⇒ ns-plain-one-line(c)
function ns_plain([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if ($context -in @('flow-out', 'flow-in')) {
        if (ns_plain_multi_line($n, $context)) { return $true }

        $script:current_index = $mem_index
        return $false
    }

    if ($context -in @('block-key', 'flow-key')) {
        if (ns_plain_one_line($context)) { return $true }

        $script:current_index = $mem_index
        return $false
    }

    return $false
}

# [132] nb-ns-plain-in-line(c) ::= ( s-white* ns-plain-char(c) )*
function nb_ns_plain_in_line([string] $context) {
    while ($true) {
        while (s_white) {}

        if (-not (ns_plain_char($context))) { return $true }
    }
}

# [133] ns-plain-one-line(c) ::= ns-plain-first(c) nb-ns-plain-in-line(c)
function ns_plain_one_line([string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (ns_plain_first($context))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (nb_ns_plain_in_line($context))) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [134] s-ns-plain-next-line(n,c) ::= s-flow-folded(n)
#                                     ns-plain-char(c) nb-ns-plain-in-line(c)
function s_ns_plain_next_line([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (s_flow_folded($n))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (ns_plain_char($context))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (nb_ns_plain_in_line($context))) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [135] ns-plain-multi-line(n,c) ::= ns-plain-one-line(c)
#                                    s-ns-plain-next-line(n,c)*
function ns_plain_multi_line([int] $n, [string] $context) {
    if (-not (ns_plain_one_line($context))) {
        return $false
    }

    while (s_ns_plain_next_line($n, $context)) {}

    return $true
}

# [136] in-flow(c) ::= c = flow-out  ⇒ flow-in
#                      c = flow-in   ⇒ flow-in
#                      c = block-key ⇒ flow-key
#                      c = flow-key  ⇒ flow-key
function in_flow([string] $context) {
    if ($context -in @('flow-out', 'flow-in')) {
        return 'flow-in'
    }
    if ($context -in @('block-key', 'flow-key')) {
        return 'flow-key'
    }
}

# [137] c-flow-sequence(n,c) ::= “[” s-separate(n,c)?
#                                ns-s-flow-seq-entries(n,in-flow(c))? “]”
function c_flow_sequence([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if ($yaml_flow[$current_index] -ne '[') {
        return $false
    }

    $script:current_index += 1

    s_separate($n, $context)

    [string] $new_context = in_flow($context)

    ns_s_flow_seq_entries($n, $new_context)

    if ($yaml_flow[$current_index] -ne ']') {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [138] ns-s-flow-seq-entries(n,c) ::= ns-flow-seq-entry(n,c) s-separate(n,c)?
#                                      ( “,” s-separate(n,c)?
#                                      ns-s-flow-seq-entries(n,c)? )?
function ns_s_flow_seq_entries([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (ns_flow_seq_entry($n, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    s_separate($n, $context)

    if ($yaml_flow[$current_index] -ne ',') {
        return $true
    }

    $script:current_index += 1

    s_separate($n, $context)

    ns_s_flow_seq_entries($n, $context)

    return $true
}

# [139] ns-flow-seq-entry(n,c) ::= ns-flow-pair(n,c) | ns-flow-node(n,c)
function ns_flow_seq_entry([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (ns_flow_pair($n, $context)) {
        return $true
    }

    $script:current_index = $mem_index
    
    if (ns_flow_node($n, $context)) {
        return $true
    }

    $script:current_index = $mem_index
    return $false
}

# [140] c-flow-mapping(n,c) ::= “{” s-separate(n,c)?
#                               ns-s-flow-map-entries(n,in-flow(c))? “}”
function c_flow_mapping([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if ($yaml_flow[$current_index] -ne '{') {
        return $false
    }

    $script:current_index += 1

    s_separate($n, $context)

    [string] $new_context = in_flow($context)

    ns_s_flow_map_entries($n, $new_context)

    if ($yaml_flow[$current_index] -ne '}') {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [141] ns-s-flow-map-entries(n,c) ::= ns-flow-map-entry(n,c) s-separate(n,c)?
#                                      ( “,” s-separate(n,c)?
#                                      ns-s-flow-map-entries(n,c)? )?
function ns_s_flow_map_entries([int] $n, [string] $context) {
    if (-not (ns_flow_map_entry($n, $context))) {
        return $false
    }

    s_separate($n, $context)

    if ($yaml_flow[$current_index] -ne ',') {
        return $true
    }

    $script:current_index += 1

    s_separate($n, $context)

    ns_s_flow_map_entries($n, $context)

    return $true
}

# [142] ns-flow-map-entry(n,c) ::= ( “?” s-separate(n,c)
#                                  ns-flow-map-explicit-entry(n,c) )
#                                  | ns-flow-map-implicit-entry(n,c)
function ns_flow_map_entry([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (ns_flow_map_implicit_entry($n, $context)) { return $true }

    if ($yaml_flow[$current_index] -ne '?' ) {
        return $false
    }

    $current_index += 1

    if (-not (s_separate($n, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (ns_flow_map_explicit_entry($n, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [143] ns-flow-map-explicit-entry(n,c) ::= ns-flow-map-implicit-entry(n,c)
#                                           | ( e-node /* Key */
#                                           e-node /* Value */ )
function ns_flow_map_explicit_entry([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (ns_flow_map_implicit_entry($n, $context)) {
        return $true
    }

    if (-not (e_node)) {
        return $false
    }

    if (-not (e-node)) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [144] ns-flow-map-implicit-entry(n,c) ::= ns-flow-map-yaml-key-entry(n,c)
#                                           | c-ns-flow-map-empty-key-entry(n,c)
#                                           | c-ns-flow-map-json-key-entry(n,c)
function ns_flow_map_implicit_entry([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (ns_flow_map_yaml_key_entry($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (c_ns_flow_map_empty_key_entry($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (c_ns_flow_map_json_key_entry($n, $context)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [145] ns-flow-map-yaml-key-entry(n,c) ::= ns-flow-yaml-node(n,c)
#                                           ( ( s-separate(n,c)?
#                                           c-ns-flow-map-separate-value(n,c) )
#                                           | e-node )
function ns_flow_map_yaml_key_entry([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (ns_flow_yaml_node($n, $context)) { return $true }

    s_separate($n, $context)

    [int] $temp_index = $script:current_index

    if (c_ns_flow_map_separate_value($n, $context)) { return $true }

    $script:current_index = $temp_index

    if (e_node) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [146] c-ns-flow-map-empty-key-entry(n,c) ::= e-node /* Key */
#                                              c-ns-flow-map-separate-value(n,c)
function c_ns_flow_map_empty_key_entry([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (e_node)) {
        $script:current_index = $mem_index
        return $false
    }

    if (c_ns_flow_map_separate_value($n, $context)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [147] c-ns-flow-map-separate-value(n,c) ::= “:” ( ( s-separate(n,c)
#                                             ns-flow-node(n,c) )
#                                             | e-node /* Value */ )
function c_ns_flow_map_separate_value([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (c_mapping_value)) { return $false }

    [int] $last_valid_index = $script:current_index

    if (s_separate($n, $context)) {
        if (ns_flow_node($n, $context)) {
            return $true
        }
    }

    $script:current_index = $last_valid_index

    if (e_node) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [148] c-ns-flow-map-json-key-entry(n,c) ::= c-flow-json-node(n,c)
#                                             ( ( s-separate(n,c)?
#                                             c-ns-flow-map-adjacent-value(n,c) )
#                                             | e-node )
function c_ns_flow_map_json_key_entry([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (c_flow_json_node($n, $context))) { return $false }

    [int] $last_valid_index = $script:current_index

    if (s_separate($n, $context)) {
        if (c_ns_flow_map_adjacent_value($n, $context)) { return $true}
    }

    $script:current_index = $last_valid_index

    if (e_node) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [149] c-ns-flow-map-adjacent-value(n,c) ::= “:” ( ( s-separate(n,c)?
#                                             ns-flow-node(n,c) )
#                                             | e-node ) /* Value */
function c_ns_flow_map_adjacent_value([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (c_mapping_value)) { return $false }

    s_separate($n, $context)

    if (ns_flow_node($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (e_node) { return $true }
    
    $script:current_index = $mem_index
    return $false
}

# [150] ns-flow-pair(n,c) ::= ( “?” s-separate(n,c)
#                             ns-flow-map-explicit-entry(n,c) )
#                             | ns-flow-pair-entry(n,c)
function ns_flow_pair([int] $n, [string] $context) {
    if (ns_flow_pair_entry($n, $context)) { return $true }

    [int] $mem_index = $script:current_index

    if (-not (c_mapping_key)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (s_separate($n, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (ns_flow_map_explicit_entry($n, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [151] ns-flow-pair-entry(n,c) ::= ns-flow-pair-yaml-key-entry(n,c)
#                                   | c-ns-flow-map-empty-key-entry(n,c)
#                                   | c-ns-flow-pair-json-key-entry(n,c)
function ns_flow_pair_entry([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (ns_flow_pair_yaml_key_entry($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (c_ns_flow_map_empty_key_entry($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (c_ns_flow_pair_json_key_entry($n, $context)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [152] ns-flow-pair-yaml-key-entry(n,c) ::= ns-s-implicit-yaml-key(flow-key)
#                                            c-ns-flow-map-separate-value(n,c)
function ns_flow_pair_yaml_key_entry([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (ns_s_implicit_yaml_key('flow-key'))) {
        $script:current_index = $mem_index
        return $false
    }

    if (c_ns_flow_map_separate_value($n, $context)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [153] c-ns-flow-pair-json-key-entry(n,c) ::= c-s-implicit-json-key(flow-key)
#                                              c-ns-flow-map-adjacent-value(n,c)
function c_ns_flow_pair_json_key_entry([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (c_s_implicit_json_key('flow-key'))) {
        $script:current_index = $mem_index
        return $false
    }

    if (c_ns_flow_map_adjacent_value($n, $context)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [154] ns-s-implicit-yaml-key(c) ::= ns-flow-yaml-node(n/a,c) s-separate-in-line?
#                                     /* At most 1024 characters altogether */
function ns_s_implicit_yaml_key([string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (ns_flow_yaml_node(0, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    s_separate_in_line

    return $true
}

# [155] c-s-implicit-json-key(c) ::= c-flow-json-node(n/a,c) s-separate-in-line?
#                                    /* At most 1024 characters altogether */
function c_s_implicit_json_key([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (-not (c_flow_json_node(0, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    s_separate_in_line

    return $true
}

# [156] ns-flow-yaml-content(n,c) ::= ns-plain(n,c) 
function ns_flow_yaml_content([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (ns_plain($n, $context)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [157] c-flow-json-content(n,c) ::= c-flow-sequence(n,c) | c-flow-mapping(n,c)
#                                    | c-single-quoted(n,c) | c-double-quoted(n,c)
function c_flow_json_content([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (c_flow_sequence($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (c_flow_mapping($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (c_single_quoted($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (c_double_quoted($n, $context)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [158] ns-flow-content(n,c) ::= ns-flow-yaml-content(n,c) | c-flow-json-content(n,c)
function ns_flow_content([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (ns_flow_yaml_content($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (c_flow_json_content($n, $context)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [159] ns-flow-yaml-node(n,c) ::= c-ns-alias-node
#                                  | ns-flow-yaml-content(n,c)
#                                  | ( c-ns-properties(n,c)
#                                  ( ( s-separate(n,c)
#                                  ns-flow-yaml-content(n,c) )
#                                  | e-scalar ) )
function ns_flow_yaml_node([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (c_ns_alias_node) { return $true }

    $script:current_index = $mem_index

    if (ns_flow_yaml_content($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (-not (c_ns_properties($n, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    if ((s_separate($n, $context)) -and (ns_flow_yaml_content($n, $context))) {
        return $true
    }

    if (e_scalar) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [160] c-flow-json-node(n,c) ::= ( c-ns-properties(n,c) s-separate(n,c) )?
#                                 c-flow-json-content(n,c)
function c_flow_json_node([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (c_ns_properties($n, $context)) {
        if (-not (s_separate($n, $context))) {
            $script:current_index = $mem_index
        }
    }

    if (c_flow_json_content($n, $context)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [161] ns-flow-node(n,c) ::= c-ns-alias-node
#                             | ns-flow-content(n,c)
#                             | ( c-ns-properties(n,c)
#                             ( ( s-separate(n,c)
#                             ns-flow-content(n,c) )
#                             | e-scalar ) )
function ns_flow_node([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (c_ns_alias_node) { return $true }

    $script:current_index = $mem_index

    if (ns_flow_content($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (-not (c_ns_properties($n, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    if ((s_separate($n, $context)) -and (ns_flow_content($n, $context))) {
        return $true
    }

    if (e_scalar) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [162] c-b-block-header(m,t) ::= ( ( c-indentation-indicator(m)
#                                 c-chomping-indicator(t) )
#                                 | ( c-chomping-indicator(t)
#                                 c-indentation-indicator(m) ) )
#                                 s-b-comment
function c_b_block_header([int] $m) {
    [int] $mem_index = $script:current_index

    if ((c_indentation_indicator($m)) -and (c_chomping_indicator)) {
        if (s_b_comment) {
            return $true
        }
    }

    $script:current_index = $mem_index

    if ((c_chomping_indicator) -and (c_indentation_indicator($m))) {
        if (s_b_comment) {
            return $true
        }
    }

    $script:current_index = $mem_index
    return $false
}

# [163] c-indentation-indicator(m) ::= ns-dec-digit ⇒ m = ns-dec-digit - #x30
#                                      /* Empty */  ⇒ m = auto-detect()
function c_indentation_indicator([int] $m) {
    [int] $mem_index = $script:current_index

    if (ns_dec_digit) {
        if ($m -eq 0) {
            while (s_space) {
                $m += 1
            }
        }

        if ($m -eq 0) {
            $script:current_index = $mem_index
            return $false
        }

        $script:m = $m
        return $true
    }

    $script:current_index = $mem_index
    return $false
}

# [164] c-chomping-indicator(t) ::= “-”         ⇒ t = strip
#                                   “+”         ⇒ t = keep
#                                   /* Empty */ ⇒ t = clip
function c_chomping_indicator {
    if ($yaml_flow[$current_index] -eq '-') {
        $script:t = 'strip'
        return $true
    }

    if ($yaml_flow[$current_index] -eq '+') {
        $script:t = 'keep'
        return $true
    }

    if ($yaml_flow[$current_index] -eq '') {
        $script:t = 'clip'
        return $true
    }

    return $false
}

# [165] b-chomped-last(t) ::= t = strip ⇒ b-non-content
#                             t = clip  ⇒ b-as-line-feed
#                             t = keep  ⇒ b-as-line-feed
function b_chomped_last {
    if ($script:t -eq 'strip') { return b_non_content }

    if ($script:t -eq 'clip') { return b_as_line_feed }

    if ($script:t -eq 'keep') { return b_as_line_feed }

    return $false
}

# [166] l-chomped-empty(n,t) ::= t = strip ⇒ l-strip-empty(n)
#                                t = clip  ⇒ l-strip-empty(n)
#                                t = keep  ⇒ l-keep-empty(n)
function l_chomped_empty([int] $n) {
    if ($script:t -eq 'strip') { return l_strip_empty($n) }

    if ($script:t -eq 'clip') { return l_strip_empty($n) }

    if ($script:t -eq 'keep') { return l_keep_empty($n) }

    return $false
}

# [167] l-strip-empty(n) ::= ( s-indent(≤n) b-non-content )*
#                            l-trail-comments(n)?
function l_strip_empty([int] $n) {
    [int] $mem_index = $script:current_index

    while (-not ((s_indent_le($n)) -and (b_non_content))) {}

    if (l_trail_comments($n)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [168] l-keep-empty(n) ::= l-empty(n,block-in)*
#                           l-trail-comments(n)?
function l_keep_empty([int] $n) {
    while (l_empty($n, 'block-in')) {}

    l_trail_comments($n)

    return $true
}

# [169] l-trail-comments(n) ::= s-indent(<n) c-nb-comment-text b-comment
#                               l-comment*
function l_trail_comments([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (s_indent_lt($n))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (c_nb_comment_text)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (b_comment)) {
        $script:current_index = $mem_index
        return $false
    }

    while (l_comment) {}

    return $true
}

# [170] c-l+literal(n) ::= “|” c-b-block-header(m,t)
#                          l-literal-content(n+m,t)
function c_l_literal([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (c_literal)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (c_b_block_header)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (l_literal_content($n+$script:m))) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [171] l-nb-literal-text(n) ::= l-empty(n,block-in)*
#                                s-indent(n) nb-char+
function l_nb_literal_text([int] $n) {
    [int] $mem_index = $script:current_index

    while (l_empty($n, 'block-in')) {}

    if (-not (s_indent($n))) {
        $script:current_index = $mem_index
        return $false
    }

    [int] $is_char = 0

    while (nb_char) { $is_char += 1 }

    if ($is_char -lt 1) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [172] b-nb-literal-next(n) ::= b-as-line-feed
#                                l-nb-literal-text(n)
function b_nb_literal_next([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (b_as_line_feed)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (l_nb_literal_text($n))) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [173] l-literal-content(n,t) ::= ( l-nb-literal-text(n) b-nb-literal-next(n)*
#                                  b-chomped-last(t) )?
#                                  l-chomped-empty(n,t)
function l_literal_content([int] $n) {
    [int] $mem_index = $script:current_index
    [bool] $is_first_condition = $false

    if (l_nb_literal_text($n)) {
        while (b_nb_literal_next) {}

        if (l_chomped_empty($n)) { $is_first_condition = $true }
    }

    if (-not ($is_first_condition)) {
        $script:current_index = $mem_index
    }

    if (l_chomped_empty($n)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [174] c-l+folded(n) ::= “>” c-b-block-header(m,t)
#                         l-folded-content(n+m,t)
function c_l_folded([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (c_folded)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (c_b_block_header)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (l_folded_content($n+$script:m))) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [175] s-nb-folded-text(n) ::= s-indent(n) ns-char nb-char*
function s_nb_folded_text([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (s_indent($n))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (ns_char)) {
        $script:current_index = $mem_index
        return $false
    }

    while (nb_char) {}

    return $true
}

# [176] l-nb-folded-lines(n) ::= s-nb-folded-text(n)
#                                ( b-l-folded(n,block-in) s-nb-folded-text(n) )*
function l_nb_folded_lines([int] $n) {
    if (-not (s_nb_folded_text)) { return $false }

    while ($true) {
        [int] $last_valid_index = $script:current_index
        if (-not (b_l_folded($n, 'block-in'))) {
            return $true
        }

        if (-not (s_nb_folded_text($n))) {
            $script:current_index = $last_valid_index
            return $true
        }
    }
    return $false
}

# [177] s-nb-spaced-text(n) ::= s-indent(n) s-white nb-char*
function s_nb_spaced_text([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (s_indent($n))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (s_white)) {
        $script:current_index = $mem_index
        return $false
    }

    while (nb_char) {}

    return $true
}

# [178] b-l-spaced(n) ::= b-as-line-feed
#                         l-empty(n,folded)*
function b_l_spaced([int] $n) {
    if (-not (b_as_line_feed)) { return $false }

    while (l_empty($n, 'folded')) {}

    return $true
}

# [179] l-nb-spaced-lines(n) ::= s-nb-spaced-text(n)
#                                ( b-l-spaced(n) s-nb-spaced-text(n) )*
function l_nb_spaced_lines([int] $n) {
    if (-not (s_nb_spaced_text($n))) { return $false }

    while ($true) {
        [int] $last_valid_index = $script:current_index

        if (-not (b_l_spaced($n))) { return $true }
        if (-not (s_nb_spaced_text($n))) {
            $script:current_index = $last_valid_index
            return $true
        }
    }
    return $false
}

# [180] l-nb-same-lines(n) ::= l-empty(n,block-in)*
#                              ( l-nb-folded-lines(n) | l-nb-spaced-lines(n) )
function l_nb_same_lines([int] $n) {
    while (l_empty($n, 'block-in')) {}

    [int] $mem_index = $script:current_index

    if (l_nb_folded_lines($n)) { return $true }

    $script:current_index = $mem_index

    if (l_nb_spaced_lines($n)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [181] l-nb-diff-lines(n) ::= l-nb-same-lines(n)
#                              ( b-as-line-feed l-nb-same-lines(n) )*
function l_nb_diff_lines([int] $n) {
    if (-not (l_nb_same_lines($n))) { return $false }

    while ($true) {
        [int] $last_valid_index = $script:current_index

        if (-not (b_as_line_feed)) { return $true }

        if (-not (l_nb_same_lines($n))) {
            $script:current_index = $last_valid_index
            return $true
        }
    }

    return $false
}

# [182] l-folded-content(n,t) ::= ( l-nb-diff-lines(n) b-chomped-last(t) )?
#                                 l-chomped-empty(n,t)
function l_folded_content([int] $n) {
    [int] $mem_index = $script:current_index

    l_nb_diff_lines($n)

    if (-not (b_chomped_last)) {
        $script:current_index = $mem_index
    }

    if (l_chomped_empty($n)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [183] l+block-sequence(n) ::= ( s-indent(n+m) c-l-block-seq-entry(n+m) )+
#                               /* For some fixed auto-detected m > 0 */
function l_block_sequence([int] $n) {
    [int] $count = 0
    [int] $indent = $n + $script:m
    [int] $mem_index = $script:current_index

    while (s_indent($indent) -and c_l_block_seq_entry($indent)) {
        $mem_index = $script:current_index
        $count += 1
    }

    if ($count -ge 1) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [184] c-l-block-seq-entry(n) ::= “-” /* Not followed by an ns-char */
#                                  s-l+block-indented(n,block-in)
function c_l_block_seq_entry([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (c_sequence_entry)) {
        $script:current_index = $mem_index
        return $false
    }

    if (s_l_block_indented($n, 'block-in')) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [185] s-l+block-indented(n,c) ::= ( s-indent(m)
#                                   ( ns-l-compact-sequence(n+1+m)
#                                   | ns-l-compact-mapping(n+1+m) ) )
#                                   | s-l+block-node(n,c)
#                                   | ( e-node s-l-comments )
function s_l_block_indented([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (s_l_block_node($n, $context)) { return $true }

    $script:current_index = $mem_index

    if ((e_node) -and (s_l_comments)) { return $true }

    $script:current_index = $mem_index

    if (-not (s_indent($script:m))) { return $false }

    $indent = $n + 1 + $script:m

    if (ns_l_compact_sequence($indent)) { return $true }

    if (ns_l_compact_mapping($indent)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [186] ns-l-compact-sequence(n) ::= c-l-block-seq-entry(n)
#                                    ( s-indent(n) c-l-block-seq-entry(n) )*
function ns_l_compact_sequence([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (c_l_block_seq_entry($n))) {
        $script:current_index = $mem_index
        return $false
    }

    $last_valid_index = $script:current_index

    while ((s_indent($n)) -and (c_l_block_seq_entry($n))) {
        $last_valid_index = $script:current_index
    }

    $script:current_index = $last_valid_index
    return $true
}

# [187] l+block-mapping(n) ::= ( s-indent(n+m) ns-l-block-map-entry(n+m) )+
#                              /* For some fixed auto-detected m > 0 */
function l_block_mapping([int] $n) {
    [int] $indent = $n + $script:current_index
    [int] $count = 0

    while ($true) {
        [int] $mem_index = $script:current_index

        if (-not (s_indent($indent))) { break }

        if (-not (ns_l_block_map_entry($indent))) {
            $script:current_index = $mem_index
            break
        }

        $count += 1
    }

    if ($count -ge 1) { return $true }

    return $false
}

# [188] ns-l-block-map-entry(n) ::= c-l-block-map-explicit-entry(n)
#                                   | ns-l-block-map-implicit-entry(n)
function ns_l_block_map_entry([int] $n) {
    [int] $mem_index = $script:current_index

    if (c_l_block_map_explicit_entry($n)) { return $true }
    $script:current_index = $mem_index

    if (ns_l_block_map_implicit_entry($n)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [189] c-l-block-map-explicit-entry(n) ::= c-l-block-map-explicit-key(n)
#                                           ( l-block-map-explicit-value(n)
#                                           | e-node )
function c_l_block_map_explicit_entry([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (c_l_block_map_explicit_key($n))) {
        $script:current_index = $mem_index
        return $false
    }

    $last_valid_index = $script:current_index

    if (l_block_map_explicit_value($n)) { return $true }
    $script:current_index = $last_valid_index

    if (e_node) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [190] c-l-block-map-explicit-key(n) ::= “?” s-l+block-indented(n,block-out)
function c_l_block_map_explicit_key([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (c_mapping_key)) {
        $script:current_index = $mem_index
        return $false
    }

    if (s_l_block_indented($n, 'block-out')) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [191] l-block-map-explicit-value(n) ::= s-indent(n)
#                                         “:” s-l+block-indented(n,block-out)
function l_block_map_explicit_value([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (s_indent($n))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (c_mapping_value)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (s_l_block_indented($n, 'block-out'))) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [192] ns-l-block-map-implicit-entry(n) ::= ( ns-s-block-map-implicit-key
#                                            | e-node )
#                                            c-l-block-map-implicit-value(n)
function ns_l_block_map_implicit_entry([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (ns_s_block_map_implicit_key)) {
        if (-not (e_node)) {
            $script:current_index = $mem_index
            return $false
        }
    }

    if (-not (c_l_block_map_implicit_value($n))) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [193] ns-s-block-map-implicit-key ::= c-s-implicit-json-key(block-key)
#                                       | ns-s-implicit-yaml-key(block-key)
function ns_s_block_map_implicit_key {
    [int] $mem_index = $script:current_index

    if (c_s_implicit_json_key('block-key')) { return $true }

    $script:current_index = $mem_index

    if (ns_s_implicit_yaml_key('block-key')) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [194] c-l-block-map-implicit-value(n) ::= “:” ( s-l+block-node(n,block-out)
#                                           | ( e-node s-l-comments ) )
function c_l_block_map_implicit_value([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (c_mapping_value)) {
        $script:current_index = $mem_index
        return $false
    }

    if (s_l_block_node($n, 'block-out')) { return $true }

    if (-not (e_node)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (s_l_comments)) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [195] ns-l-compact-mapping(n) ::= ns-l-block-map-entry(n)
#                                   ( s-indent(n) ns-l-block-map-entry(n) )*
function ns_l_compact_mapping([int] $n) {
    if (-not (ns_l_block_map_entry($n))) {
        return $false
    }

    while ($true) {
        [int] $mem_index = $script:current_index
        if (-not (s_indent($n))) { return $true }
        if (-not (ns_l_block_map_entry($n))) {
            $script:current_index = $mem_index
            return $true
        }
    }
    return $true
}

# [196] s-l+block-node(n,c) ::= s-l+block-in-block(n,c) | s-l+flow-in-block(n)
function s_l_block_node([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (s_l_block_in_block($n, $context)) { return $true }

    $script:current_index = $mem_index

    if (s_l_flow_in_block($n)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [197] s-l+flow-in-block(n) ::= s-separate(n+1,flow-out)
#                                ns-flow-node(n+1,flow-out) s-l-comments
function s_l_flow_in_block([int] $n) {
    [int] $mem_index = $script:current_index

    if (-not (s_separate($n+1, 'flow-out'))) { return $false }

    if (-not (ns_flow_node($n+1, 'flow-out'))) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (s_l_comments)) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [198] s-l+block-in-block(n,c) ::= s-l+block-scalar(n,c) | s-l+block-collection(n,c)
function s_l_block_in_block([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    if (s_l_block_scalar) { return $true }

    $script:current_index = $mem_index

    if (s_l_block_collection($n, $context)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [199] s-l+block-scalar(n,c) ::= s-separate(n+1,c)
#                                 ( c-ns-properties(n+1,c) s-separate(n+1,c) )?
#                                 ( c-l+literal(n) | c-l+folded(n) )
function s_l_block_scalar([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index
    [int] $indent = $n + 1

    if (-not (s_separate($indent, $context))) {
        $script:current_index = $mem_index
        return $false
    }

    [int] $last_valid_index = $script:current_index

    if (-not ((c_ns_properties($indent, $context)) -and (s_separate($indent, $context)))) {
        $script:current_index = $last_valid_index
    }

    if (c_l_literal($n)) { return $true }
    if (c_l_folded($n)) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [200] s-l+block-collection(n,c) ::= ( s-separate(n+1,c) c-ns-properties(n+1,c) )?
#                                     s-l-comments
#                                     ( l+block-sequence(seq-spaces(n,c))
#                                     | l+block-mapping(n) )
function s_l_block_collection([int] $n, [string] $context) {
    [int] $mem_index = $script:current_index

    $indent = $n + 1

    if (-not ((s_separate($indent, $context)) -and (c_ns_properties($indent, $context)))) {
        $script:current_index = $mem_index
    }

    if (-not (s_l_comments)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (l_block_sequence)) {
        $script:current_index = $mem_index
        return $false
    }
    
    $n = seq_spaces($n, $context)
    
    if (l_block_mapping) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [201] seq-spaces(n,c) ::= c = block-out ⇒ n-1
#                           c = block-in  ⇒ n
function seq_spaces([int] $n, [string] $context) {
    if ($context -eq 'block-out') { return ($n-1) }
    if ($context -eq 'block-in') { return $n }
    return -1
}

# [202] l-document-prefix ::= c-byte-order-mark? l-comment*
function l_document_prefix {
    c_byte_order_mark

    while (l_comment) { }

    return $true
}

# [203] c-directives-end ::= “-” “-” “-”
function c_directives_end {
    [int] $mem_index = $script:current_index

    if (-not (c_sequence_entry)) { return $false }
    if (-not (c_sequence_entry)) {
        $script:current_index = $mem_index
        return $false
    }
    if (-not (c_sequence_entry)) {
        $script:current_index = $mem_index
        return $false
    }
    return $true
}

# [204] c-document-end ::= “.” “.” “.”
function c_document_end {
    [int] $mem_index = $script:current_index

    if ($yaml_flow[$current_index] -eq '.') {
        $script:current_index += 1
    } else {
        return $false
    }

    if ($yaml_flow[$current_index] -eq '.') {
        $script:current_index += 1
    } else {
        $script:current_index = $mem_index
        return $false
    }

    if ($yaml_flow[$current_index] -eq '.') {
        $script:current_index += 1
    } else {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [205] l-document-suffix ::= c-document-end s-l-comments
function l_document_suffix {
    [int] $mem_index = $script:current_index

    if (-not (c_document_end)) { return $false }
    if (-not (s_l_comments)) {
        $script:current_index = $mem_index
        return $false
    }
    return $true
}

# [206] c-forbidden ::= /* Start of line */
#                       ( c-directives-end | c-document-end )
#                       ( b-char | s-white | /* End of file */ )
function c_forbidden {
    [int] $mem_index = $script:current_index

    $script:current_index -= 1

    if (-not (b_break)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (c_directives_end)) {
        if (-not (c_document_end)) {
            return $false
        }
    }

    if (b_char) { return $true }
    if (s_white) { return $true }
    if ($script:current_index -eq $yaml_flow.Length) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [207] l-bare-document ::= s-l+block-node(-1,block-in)
#                           /* Excluding c-forbidden content */
function l_bare_document {
    return (s_l_block_node(-1, 'block-in'))
}

# [208] l-explicit-document ::= c-directives-end
#                               ( l-bare-document
#                               | ( e-node s-l-comments ) )
function l_explicit_document {
    [int] $mem_index = $script:current_index

    if (-not (c_directives_end)) { return $false }
    
    [int] $last_valid_index = $script:current_index

    if (l_bare_document) { return $true }

    $script:current_index = $last_valid_index

    if (-not (e_node)) {
        $script:current_index = $mem_index
        return $false
    }

    if (-not (s_l_comments)) {
        $script:current_index = $mem_index
        return $false
    }

    return $true
}

# [209] l-directive-document ::= l-directive+
#                                l-explicit-document
function l_directive_document {
    [int] $mem_index = $script:current_index

    [int] $count = 0

    while (l_directive) { $count += 1 }

    if ($count -lt 1) { return $false }

    if (l_explicit_document) { return $true }

    $script:current_index = $mem_index
    return $false
}

# [210] l-any-document ::= l-directive-document
#                          | l-explicit-document
#                          | l-bare-document
function l_any_document {
    if (l_directive_document) { return $true }

    if (l_explicit_document) { return $true }

    if (l_bare_document) { return $true }
    
    return $false
}

# [211] l-yaml-stream ::= l-document-prefix* l-any-document?
#                         ( l-document-suffix+ l-document-prefix* l-any-document?
#                         | l-document-prefix* l-explicit-document? )*
function l_yaml_stream {
    while (l_document_prefix) {}

    l_any_document

    [int] $count = 0

    while ($script:current_index -lt $yaml_flow.Length) {
        while (l_document_suffix) { $count += 1 }

        if ($count -gt 1) {
            while (l_document_prefix) {}
            l_any_document
        } else {
            while (l_document_prefix) {}
            l_explicit_document
        }
    }
    
    return $false
}
