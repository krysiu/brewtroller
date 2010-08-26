#ifndef _MENU_H
#define _MENU_H

#include <WProgram.h>

#define ALLOC_BLOCK 5

typedef struct {
  char name[21];
  byte value;
} menuItem;


class menu
{
public:
	menu(void);
	void begin(byte, byte);
	void clear(void);
	void addItem(char[], byte);
	void setSelected(byte);
	byte getSelected(void);
	boolean refreshDisp(void);
	void getRow(byte, char[]);
	byte getValue(void);
	byte getCursor(void);
	byte getItemCount(void);
	void setSelectedByValue(byte);
private:
	byte 	_rows,
			_cols,
			_itemCount,
			_selected,
			_topItem,
			_alloced;
			
	menuItem *_menuItems;
};

#endif
