'use-strict';

import React,{Component,PropTypes} from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import MainMenuCmp from '../components/mainMenuCmp';

export class MainMenuCnt extends Component
{
  constructor(props)
  {
    super(props);
  }

  render()
  {
    console.log( 'MAINMENUCNT - see state:', this.props.LoginSignUpReducer );
    return(
      <MainMenuCmp isUserLogged={this.props.LoginSignUpReducer.isLogged}/>
    );
  }
}

//------------------------------------------------------------------------------
// Special functions to connect with redux
//------------------------------------------------------------------------------
function mapStateToProps( state, props )
{
  console.log( '****',state,'-', props );
  return state; //.LoginSignUpReducer;
}

/*function mapDispatchToProps( dispatch, props )
{
  return {
    loginSignupActions:bindActionCreators( LoginSignupActions, dispatch )
  };
}*/

export default connect( mapStateToProps /*, mapDispatchToProps*/ )(MainMenuCnt);
