'use-strict';

import React,{Component} from 'react';
import Dialog from 'react-toolbox/lib/dialog';
import { RadioGroup, RadioButton } from 'react-toolbox';
import Switch from 'react-toolbox/lib/switch';
import {Button} from 'react-toolbox/lib/button';

import {Lang} from '../modules/languageCtrl';

export default class TaleMenuCmp extends Component
{
  constructor(props)
  {
    super(props);
    this.state = {
      active:false,
      actions:[
        {
          label: Lang.trans('template.storyModelMenu.close'),
          onClick: this.onShowMenu.bind(this)
        }
      ],
      langValue:Lang.getCurrentId(),
      switchMusic:false,
      switchFx:false
    };
    /*
    this.actions=[
      {
        label: Lang.trans('template.storyModelMenu.close'),
        onClick: this.onShowMenu.bind(this)
      }
    ];
    */
  }

  render()
  {
    return(
      <div>
        <div className="top">
          <img src='resources/img/button_menu.png' className='menuButton' onClick={this.onShowMenu.bind(this)}/>
        </div>
        <div>
          <Dialog actions={this.state.actions} active={this.state.active} title={Lang.trans('template.storyModelMenu.title')}>
            <p>{Lang.trans('template.storyModelMenu.selectLanguage')}</p>
            <section>
              <RadioGroup name='language' value={this.state.langValue} onChange={this.onChangeLanguage.bind(this)}>
                <RadioButton label={Lang.trans('template.language.spanish')} value='es'/>
                <RadioButton label={Lang.trans('template.language.english')} value='en'/>
              </RadioGroup>
            </section>
            <p>{Lang.trans('template.storyModelMenu.sounds')}</p>
            <section>
              <Switch checked={this.state.switchMusic} label={Lang.trans('template.storyModelMenu.music')} onChange={this.onChangeSounds.bind(this, 'switchMusic')}/>
              <Switch checked={this.state.switchFx} label={Lang.trans('template.storyModelMenu.fx')} onChange={this.onChangeSounds.bind(this, 'switchFx')}/>
            </section>
            <p>{Lang.trans('template.storyModelMenu.exitquestion')}</p>
            <Button label={Lang.trans('template.storyModelMenu.exit')} flat onClick={this.onExitTale.bind(this)}/>
          </Dialog>
        </div>
      </div>
    );
  }

  onShowMenu()
  {
    this.setState( {active:!this.state.active} );
  }

  onChangeLanguage( value )
  {
    Lang.changeLanguage( value, function(){
      this.setState( {
        langValue:value,
        actions:[{label: Lang.trans('template.storyModelMenu.close'),onClick: this.onShowMenu.bind(this)}]
      } );
    }.bind(this));
  }

  onChangeSounds( field, value )
  {
    this.setState( Object.assign( {}, this.state, {[field]:value} ) );
  }

  onExitTale()
  {
    this.onShowMenu();
    this.props.exitTale();
  }
}
