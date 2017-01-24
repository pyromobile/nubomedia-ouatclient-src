export function changeAccessTap( indexTap )
{
  return {
    type:'CHANGE_ACCESS_TAP',
    currentIndexTap:indexTap
  };
}

export function cancelSignupLogin()
{
  return {
    type:'CANCEL_SIGNUP_LOGIN'
  };
}

export function errorLogin( description )
{
  return {
    type:'ERROR_LOGIN',
    description:description
  };
}

export function errorSignup( description )
{
  return {
    type:'ERROR_SIGNUP',
    description:description
  };
}

export function logged( userId, nick )
{
  return {
    type:'USER_LOGGED',
    userId:userId,
    nick:nick
  };
}

export function changedProfile( user )
{
  return {
    type: 'CHANGED_PROFILE',
    user:user
  };
}
