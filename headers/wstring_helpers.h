
#include <wchar.h>
#include <sstream>
#include <string.h>
#include <iostream>

//multibyte to wide string
std::wstring toWideString( const char* cstr )
{
	std::wostringstream os;

	size_t i;
	for (i = 0; i < strlen(cstr); i++ ){
		wchar_t wc;
		if ( -1 != ::mbtowc( &wc, &cstr[i], 1 ) ) {
			os << wc;
		}
	}

	return std::wstring( os.str() );
}

//wide to multibyte string
std::string wideToString( const std::wstring& s )
{
	std::stringstream os;
	const wchar_t* ws = s.c_str();

	size_t i;
	for (i = 0; i < s.length(); i++ ){
		char c;
		if ( -1 != ::wctomb( &c, ws[i] ) ) {
			os << c;
		}
	}

	return os.str();
}

void print_wchar(const wchar_t* cstr)
{
    std::wcout << cstr << L"\n";
}
