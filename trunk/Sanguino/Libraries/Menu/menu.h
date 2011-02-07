#ifndef _MENU_H
#define _MENU_H

#include <WProgram.h>

typedef struct {
  char name[21];
  byte value;
} menuItem;


class menu
{
public:
	menu(void);
	void begin(byte, byte, byte);
	void clear(void);
	void addItem(char[], byte);
	void addItem_P(const char *, byte);
	void setSelected(byte);
	byte getSelected(void);
	boolean refreshDisp(void);
	void getSelectedRow(char[]);
	void getVisibleRow(byte, char[]);
	byte getValue(void);
	byte getCursor(void);
	byte getItemCount(void);
	void setSelectedByValue(byte);
	void updateItem(char[], byte);
	void updateItem_P(const char *, byte);
private:
	byte 	_rows,
			_cols,
			_maxOpts,
			_itemCount,
			_selected,
			_topItem;
			
	menuItem *_menuItems;
	byte getIndexByValue(byte);
};

#endif
