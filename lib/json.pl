#!/usr/bin/perl -w
# --
# bin/cgi-bin/json.pl - json handle
# Copyright (C) 2001-2010 OTRS AG, http://otrs.org/
# --
# $Id: json.pl,v 1.13 2010/09/23 17:51:02 cr Exp $
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;

# use ../../ as lib location
use FindBin qw($Bin);
use lib "$Bin/../..";
use lib "$Bin/../../Kernel/cpan-lib";

use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::DB;
use Kernel::System::Main;
use Kernel::System::Time;
use Kernel::System::Auth;
use Kernel::System::User;
use Kernel::System::Group;
use Kernel::System::Queue;
use Kernel::System::Service;
use Kernel::System::Type;
use Kernel::System::State;
use Kernel::System::Lock;
use Kernel::System::SLA;
use Kernel::System::CustomerUser;
use Kernel::System::Ticket;
use Kernel::System::LinkObject;
use Kernel::System::JSON;
use Kernel::System::iPhone;
use Kernel::System::ITSMConfigItem;
use Kernel::System::Web::Request;
use Kernel::System::ITSMChange;
use Kernel::System::ITSMChange::ITSMWorkOrder;
use Kernel::System::ITSMChange::ITSMStateMachine;
use Kernel::System::GeneralCatalog;
use Kernel::System::XML;
use Custom::Envu::Kernel::System::Service;
use Custom::Envu::Kernel::System::Ticket;
use Custom::Envu::Kernel::System::ITSMConfigItem;
use Custom::Envu::Kernel::System::ITSMChange;
use Custom::Envu::Kernel::System::ITSMChange::ITSMWorkOrder;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.13 $) [1];

my $Self = Core->new();
my $r = shift;
print "Content-Type: text/plain; \n";
print "\n";
$r->print($Self->Dispatch());

package Core;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Dispatch {
    my ($Self) = @_;

    # common objects
    $Self->{ConfigObject} = Kernel::Config->new();
    $Self->{EncodeObject} = Kernel::System::Encode->new( %{$Self} );
    $Self->{LogObject}    = Kernel::System::Log->new(
        LogPrefix => 'OTRS-RPC',
        %{$Self},
    );
    $Self->{MainObject}           = Kernel::System::Main->new( %{$Self} );
    $Self->{DBObject}             = Kernel::System::DB->new( %{$Self} );
    $Self->{TimeObject}           = Kernel::System::Time->new( %{$Self} );
    $Self->{UserObject}           = Kernel::System::User->new( %{$Self} );
    $Self->{GroupObject}          = Kernel::System::Group->new( %{$Self} );
    $Self->{QueueObject}          = Kernel::System::Queue->new( %{$Self} );
    $Self->{ServiceObject}        = Kernel::System::Service->new( %{$Self} );
    $Self->{TypeObject}           = Kernel::System::Type->new( %{$Self} );
    $Self->{StateObject}          = Kernel::System::State->new( %{$Self} );
    $Self->{LockObject}           = Kernel::System::Lock->new( %{$Self} );
    $Self->{SLAObject}            = Kernel::System::SLA->new( %{$Self} );
    $Self->{CustomerUserObject}   = Kernel::System::CustomerUser->new( %{$Self} );
    $Self->{TicketObject}         = Kernel::System::Ticket->new( %{$Self} );
    $Self->{LinkObject}           = Kernel::System::LinkObject->new( %{$Self} );
    $Self->{JSONObject}           = Kernel::System::JSON->new( %{$Self} );
    $Self->{ParamObject}          = Kernel::System::Web::Request->new( %{$Self} );
    $Self->{iPhoneObject}         = Kernel::System::iPhone->new( %{$Self} );
    $Self->{ConfigItemObject}     = Kernel::System::ITSMConfigItem->new( %{$Self} );
    $Self->{ConfigItemObjectCustom} = Custom::Envu::Kernel::System::ITSMConfigItem->new( %{$Self} );
    $Self->{ServiceObjectCustom}  = Custom::Envu::Kernel::System::Service->new( %{$Self} );
    $Self->{TicketObjectCustom}   = Custom::Envu::Kernel::System::Ticket->new( %{$Self} );
    $Self->{ChangeObject}         = Kernel::System::ITSMChange->new( %{$Self} );
    $Self->{ChangeObjectCustom}   = Custom::Envu::Kernel::System::ITSMChange->new( %{$Self} );
    $Self->{WorkOrderObject}      = Kernel::System::ITSMChange::ITSMWorkOrder->new( %{$Self} );
    $Self->{WorkOrderObjectCustom} = Custom::Envu::Kernel::System::ITSMChange::ITSMWorkOrder->new( %{$Self} );
    $Self->{StateMachineObject}   = Kernel::System::ITSMChange::ITSMStateMachine->new( %{$Self} );
    $Self->{GeneralCatalogObject} = Kernel::System::GeneralCatalog->new( %{$Self} );
    $Self->{XMLObject}            = Kernel::System::XML->new( %{$Self} );	

    # get log filename
    if ( $Self->{ConfigObject}->Get('iPhone::LogFile') ) {
        $Self->{DebugLogFile} = $Self->{ConfigObject}->Get('iPhone::LogFile');
    }

    # set common variables
    my $User   = $Self->{ParamObject}->GetParam( Param => 'User' );
    my $Pw     = $Self->{ParamObject}->GetParam( Param => 'Password' );
    my $Object = $Self->{ParamObject}->GetParam( Param => 'Object' );
    my $Method = $Self->{ParamObject}->GetParam( Param => 'Method' );
    my $Data   = $Self->{ParamObject}->GetParam( Param => 'Data' );
    my $ParamScalar = $Self->{JSONObject}->Decode( Data => $Data );

    my %Param;
    if ($ParamScalar) {
        %Param = %{$ParamScalar};
    }
    $User ||= '';
    $Pw   ||= '';

    # inbound log
    if ( $Self->{ConfigObject}->Get('iPhone::DebugLog') ) {
        my $Message = 'User=' . $User . '&Password=****' . '&Object=' . $Object
            . '&Method=' . $Method . '&Data=' . $Data;

        $Self->Log(
            Direction => 'Inbound',
            Message   => $Message,
            )
    }

    # agent auth
    my %ParamFixed;
    if (1) {
        my $AuthObject = Kernel::System::Auth->new( %{$Self} );
        my $UserLogin = $AuthObject->Auth( User => $User, Pw => $Pw );

        if ( !$UserLogin ) {
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message  => "Auth for user $User failed!",
            );
            return $Self->Result();
        }

        # set user id
        my $UserID = $Self->{UserObject}->UserLookup(
            UserLogin => $UserLogin,
        );
        return if !$UserID;

        $ParamFixed{UserID} = $UserID;
    }

    # system auth
    else {
        my $RequiredUser     = $Self->{ConfigObject}->Get('SOAP::User');
        my $RequiredPassword = $Self->{ConfigObject}->Get('SOAP::Password');

        if (
            !defined $RequiredUser
            || !length $RequiredUser
            || !defined $RequiredPassword || !length $RequiredPassword
            )
        {
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message  => 'SOAP::User or SOAP::Password is empty, SOAP access denied!',
            );
            return $Self->Result();
        }

        if ( $User ne $RequiredUser || $Pw ne $RequiredPassword ) {
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message  => "Auth for user $User failed!",
            );
            return $Self->Result();
        }
    }

    if ( !$Self->{$Object} && $Object ne 'CustomObject' ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "No such Object $Object!",
        );
        return $Self->Result();
    }

    if ( ( $Self->{$Object} && !$Self->{$Object}->can($Method) ) && !$Self->can($Method) ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "No such method '$Method' in '$Object'!",
        );
        return $Self->Result();
    }

    if ( $Object =~ /^(DBObject|TicketObject123)$/ ) {
        $Self->{LogObject}->Log(
            Priority => 'error',
            Message  => "No access to '$Object'!",
        );
        return $Self->Result();
    }

    if ( $Object eq 'CustomObject' ) {
        my @Result = $Self->{iPhoneObject}->$Method(
            %Param,
            %ParamFixed,
        );
        return $Self->Result( \@Result );
    }
    else {
        my @Result = $Self->{$Object}->$Method(
            %Param,
            %ParamFixed,
        );
        return $Self->Result( \@Result );
    }
}

sub Result {
    my ( $Self, $Result ) = @_;

    my %ResultProtocol;

    if ($Result) {
        if ( @{$Result} ) {
            if ( @{$Result}[0] eq -1 ) {
                $ResultProtocol{Result} = 'failed';
                for my $Key (qw(error notice)) {
                    $ResultProtocol{Message} = $Self->{LogObject}->GetLogEntry(
                        Type => $Key,
                        What => 'Message',
                    );
                    last if $ResultProtocol{Message};
                }
            }

            else {
                $ResultProtocol{Result} = 'successful';
                $ResultProtocol{Data}   = $Result;
            }
        }

        else {
            $ResultProtocol{Result} = 'successful';
            $ResultProtocol{Data}   = $Result;
        }
    }

    else {
        $ResultProtocol{Result} = 'failed';
        for my $Key (qw(error notice)) {
            $ResultProtocol{Message} = $Self->{LogObject}->GetLogEntry(
                Type => $Key,
                What => 'Message',
            );
            last if $ResultProtocol{Message};
        }
    }

    # set result to a variable for easy log output
    my $JSONResult = $Self->{JSONObject}->Encode( Data => \%ResultProtocol );

    # outbound log
    if ( $Self->{ConfigObject}->Get('iPhone::DebugLog') ) {

        $Self->Log(
            Direction => 'Outbound',
            Message   => $JSONResult,
            )
    }

    return $JSONResult;
}

sub Log {
    my ( $Self, %Param ) = @_;

    my $FH;

    # open logfile
    if ( !open $FH, '>>', $Self->{DebugLogFile} ) {

        # print error screen
        print STDERR "\n";
        print STDERR " >> Can't write $Self->{LogFile}: $! <<\n";
        print STDERR "\n";
        return;
    }

    # write log file
    print $FH '[' . $Self->{TimeObject}->CurrentTimestamp() . ']';
    print $FH "[Debug] [$Param{Direction}] [$Param{Message}\n";

    # close file handle
    close $FH;
    return 1;
}

1;
