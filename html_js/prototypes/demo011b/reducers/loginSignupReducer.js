let initState = {
  currentIndexTap:0,
  error:{},
  userId:'',
  nick:''
}

export default function loginSignUpReducer(state = initState, action)
{
  let newState = null;
  switch( action.type )
  {
    case 'CHANGE_ACCESS_TAP':
      newState = Object.assign( {}, state, {currentIndexTap:action.currentIndexTap} );
      console.log('NEW STATE:',newState);
      return newState;

    case 'CANCEL_SIGNUP_LOGIN':
        newState = Object.assign( {}, initState );
        return newState;

    case 'ERROR_LOGIN':
      newState = Object.assign( {}, state, {error:{hasLoginError:true, errorDescription:action.description}} );
      return newState;

    case 'ERROR_SIGNUP':
        newState = Object.assign( {}, state, {error:{hasSignupError:true, errorDescription:action.description}} );
        return newState;

    case 'USER_LOGGED':
      newState = Object.assign( {}, state, {error:{},isLogged:true,userId:action.userId,nick:action.nick} );
      return newState;

    case 'CHANGED_PROFILE':
        newState = Object.assign( {}, state, {error:{},nick:action.user.nick} );
        return newState;

    default:
      return state;
  }
}
