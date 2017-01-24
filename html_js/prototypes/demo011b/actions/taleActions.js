

export function bookReady( pageToShow )
{
  return {
    type: 'BOOK_READY',
    pageToShow:pageToShow
  };
}

export function changePage( pageToShow )
{
  return {
    type: 'BOOK_CHANGE_PAGE',
    pageToShow:pageToShow
  };
}

export function bookClosed()
{
  return {
    type:'BOOK_CLOSED'
  }
}
