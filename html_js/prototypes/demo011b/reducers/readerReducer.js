const initialState = {
  pageToShow:null
};

export default function readerReducer(state = {}, action)
{
  let newState = null;
  switch( action.type )
  {
    case 'BOOK_READY':
      newState = {pageToShow:action.pageToShow};
      return newState;

    case 'BOOK_CHANGE_PAGE':
      newState = {pageToShow:Object.assign( {}, state.pageToShow, action.pageToShow )};
      return newState;

    case 'BOOK_CLOSED':
      newState = {};
      return newState;

    default:
      return state;
  }
}
