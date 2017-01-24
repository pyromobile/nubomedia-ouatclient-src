'use-strict';

import React,{Component} from 'react';

import TaleMenuCmp from './taleMenuCmp';
import TaleCmp from './taleCmp';

export default class FreeModeCmp extends Component
{
  constructor(props)
  {
    super(props);
  }

  render()
  {
    if( this.props.pageToShow )
    {
      return(
        <div>
          <div id="" style={{backgroundImage:'url('+this.props.pageToShow.blurImagePath+')', border:'1px solid red'}} className="imageBlur"></div>
          <TaleMenuCmp exitTale={this.props.exitTale}/>
          <TaleCmp pageToShow={this.props.pageToShow} pageNavigator={this.props.pageNavigator}/>
        </div>
      );
    }
    else
    {
      //TODO: poner un loading???
      return( <div/> );
    }
  }
}
