'use-strict';

import React,{Component,PropTypes} from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import TaleModeCmp from '../components/taleModeCmp';
import Book from '../modules/book';
import LibraryCtrl from '../modules/library';

import * as TaleActions from '../actions/taleActions';

export class TaleModeCnt extends Component
{
  constructor(props)
  {
    super(props);

    let bookId = this.props.params.bookId;
    this.book = LibraryCtrl.getInstance().getBook( bookId, 'es', true );

    //this.book = new Book( 'RdO', 'es', true );
    this.book.load( function( pageToShow ){
      this.props.taleActions.bookReady( pageToShow );
    }.bind( this ) );

    this.pageNavigator = {
      prevPage:this.onPrevPage.bind(this),
      nextPage:this.onNextPage.bind(this)
    }
  }

  render()
  {
    return(
      <TaleModeCmp pageToShow={this.props.ReaderReducer.pageToShow} pageNavigator={this.pageNavigator} exitTale={this.onExitTale.bind(this)}/>
    );
  }

  onPrevPage()
  {
    let pageToShow = this.book.prevPage();
    this.props.taleActions.changePage( pageToShow );
  }

  onNextPage()
  {
    let pageToShow = this.book.nextPage();
    this.props.taleActions.changePage( pageToShow );
  }

  onExitTale()
  {
    this.props.taleActions.bookClosed();
    this.context.router.push('/');
    this.book.release();
    this.book = null;
  }
}

TaleModeCnt.contextTypes={
  router:React.PropTypes.object
}
//------------------------------------------------------------------------------
// Special functions to connect with redux
//------------------------------------------------------------------------------
function mapStateToProps( state, props )
{
  console.log( '****',state,'-', props );
  return state; //.ReaderReducer;
}

function mapDispatchToProps( dispatch, props )
{
  return {
    taleActions:bindActionCreators( TaleActions, dispatch )
  };
}

export default connect( mapStateToProps, mapDispatchToProps )(TaleModeCnt);

/*
export default connect(
  state => ({pageToShow:state.pageToShow}),
  dispatch => ({
    taleActions:bindActionCreators( TaleActions, dispatch )
  })
)( FreeModeCnt );
*/
