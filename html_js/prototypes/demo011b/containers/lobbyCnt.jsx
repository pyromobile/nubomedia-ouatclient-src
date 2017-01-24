'use-strict';

import React,{ Component, PropTypes } from 'react';
//import { connect } from 'react-redux';
//import { bindActionCreators } from 'redux';

import LobbyCmp from '../components/LobbyCmp';
import LibraryCtrl from '../modules/library';

export default class LobbyCnt extends Component
{
  constructor(props)
  {
    super(props);

    if( this.props.params.mode != 'freemode' )
    {
      //TODO: determinar el idioma del dispositivo.
      this.books = LibraryCtrl.getInstance().getBooks( 'es' );
      this.actions = {
        selectedBook:this.onSelectedBook.bind(this),
        titleNavigation:this.onTitleNavigation.bind(this)
      }
      this.titleCurrentPosition = 0;
    }

    console.log("this.props.params - ",this.props.params);
  }

  render()
  {
    console.log( 'LOBBY_CNT - see state:' );
    return(
      <LobbyCmp books={this.books} logged={false} actions={this.actions} />
    );
  }

  onSelectedBook()
  {
    console.log( 'Libro :', this.books[this.titleCurrentPosition]);
    this.context.router.push('/'+this.props.params.mode+'/'+this.books[this.titleCurrentPosition].id);
  }

  onTitleNavigation( currentPosition )
  {
    this.titleCurrentPosition = currentPosition;
  }
}

LobbyCnt.contextTypes={
  router:React.PropTypes.object
}
