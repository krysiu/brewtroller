#include <WProgram.h>
#include <menu.h>

menu::menu() {
	_rows = 0;
	_cols = 0;
	_itemCount = 0;
	_selected = 0;
	_topItem = 0;
}

void menu::begin(byte rows, byte cols, byte maxOpts) {
	_rows = rows;
	_cols = cols;
	_maxOpts = maxOpts;
	//Free existing space
	free(_menuItems);
	//Alloc memory space
    _menuItems = (menuItem *) malloc(_maxOpts * sizeof(menuItem));
	this->clear();
}

void menu::clear() {
	_selected = 0;
	_topItem = 0;
	_itemCount = 0;
}

void menu::addItem(char disp[], byte ref) {
	if (_itemCount >= _maxOpts) return;
	strcpy(_menuItems[_itemCount].name, disp);
	_menuItems[_itemCount].value = ref;
	_itemCount++;
}

void menu::setSelected(byte selected) {
	_selected = selected;
}

void menu::setSelectedByValue(byte value) {
	if (_itemCount) {
		for (byte i = 0; i < _itemCount; i++) {
			if (_menuItems[i].value == value) {
				_selected = i;
				return;
			}
		}
	}
}

byte menu::getSelected(void) {
	return _selected;
}

boolean menu::refreshDisp(void) {
	if (_selected < _topItem) {
		_topItem = _selected;
		return 1;
	}
	if (_selected >= _topItem + _rows) {
		_topItem = _selected - _rows + 1;
		return 1;
	}
	return 0;
}

void menu::getRow(byte row, char retString[]) {
	if (_topItem + row < _itemCount) strcpy(retString, _menuItems[_topItem + row].name);
	else strcpy(retString, "");
}

byte menu::getValue() {
	return _menuItems[_selected].value;
}

byte menu::getCursor(void) {
	return _selected - _topItem;
}

byte menu::getItemCount(void) {
	return _itemCount;
}
