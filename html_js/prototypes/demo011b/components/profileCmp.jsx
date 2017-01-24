'use-strict';

import React,{ Component, PropTypes } from 'react';
import Input from 'react-toolbox/lib/input';
import { Button } from 'react-toolbox/lib/button';
import Tooltip from 'react-toolbox/lib/tooltip';

import {Lang} from '../modules/languageCtrl';

export default class ProfileCmp extends Component
{
  constructor( props )
  {
    super(props);

    this.state = {nick:this.props.nick};
  }

  render()
  {
    const TooltipCopyButton = Tooltip(Button);

    return(
      <div>
        <section>
          <Button label='Back' raised primary onClick={this.props.actions.back}/>

          <Input type='text' label='Your code' value={this.props.userCode} disabled />
          <TooltipCopyButton icon='content_copy' label='' tooltip='copy' accent />
          <Input type='text'
            label={Lang.trans('loginsignup.user')}
            icon='person'
            value={this.state.nick}
            onChange={this.handleChange.bind(this, 'nick')} />
        </section>
        <Button icon='cloud_upload' label='Apply changes' raised primary onClick={this.onUpdate.bind(this)} />
      </div>
    );
  }

  handleChange( name, value )
  {
    this.setState( Object.assign( {}, this.state, {[name]:value} ) );
  }

  onUpdate()
  {
    this.props.actions.saveChanges( Object.assign( {}, this.state) );
  }
}
