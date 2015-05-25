void lcd_init();
void lcd_cmd(uint8_t);
void lcd_data(uint8_t);
uint8_t lcd_cmd_read();
uint8_t lcd_data_read();

#define BIT_6 0
#define BIT_8 1
#define LCD_DISABLE 2
#define LCD_ENABLE 3
#define AUTO_UP 4
#define AUTO_DOWN 5
#define AUTO_LEFT 6
#define AUTO_RIGHT 7