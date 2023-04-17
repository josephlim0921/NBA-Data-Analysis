import pandas as pd
import numpy as np

# matplotlib
import matplotlib.pyplot as plt
import seaborn as sns

from matplotlib import cm 
from matplotlib.patches import Circle, Rectangle, Arc, ConnectionPatch


# nba_api
from nba_api.stats.static import players
from nba_api.stats.endpoints import shotchartdetail
from nba_api.stats.endpoints import playercareerstats


# Getting shot chart details

def player_shotchartdetail(player_name, season_id):

    # getting desired player
    nba_players = pd.DataFrame(players.get_players())
    player_finder_bool = [nba_players['full_name'] == player_name][0]
    desired_player = nba_players[player_finder_bool]

    # career dataframe
    career = playercareerstats.PlayerCareerStats(player_id=desired_player['id'])
    career_df = career.get_data_frames()[0]
   
    # team id during season
    team_id = career_df[career_df['SEASON_ID'] == season_id]['TEAM_ID']
    


    # shot chart detail
    shotchartlist = shotchartdetail.ShotChartDetail(team_id=int(team_id), 
                                                    player_id=desired_player['id'], 
                                                    season_type_all_star='Regular Season',
                                                    season_nullable=season_id,
                                                    context_measure_simple="FG3A")
    shotchart_df = shotchartlist.get_data_frames()
    
    return shotchart_df[0], shotchart_df[1]


# drawing court function

def draw_court(ax = None, color="orange", lw=1, outer_lines=False):
        
        if ax is None:
            ax = plt.gca()

        # Basketball Hoop
        hoop = Circle((0,0), radius=7.5, linewidth=lw, color=color, fill=False)

        # Backboard
        rectangle = Rectangle((-30, -12.5), width=60, height=0, linewidth=lw, color=color)

        # Paint
        # Outer Box
        outer_box = Rectangle((-80,-47.5), width=160, height=190, linewidth=lw, color=color, fill=False)
        # Inner Box
        inner_box = Rectangle((-60, -47.5), width=120, height=190, linewidth=lw, color=color, fill=False)

        # Free Throw Top Half Arc
        top_free_throw = Arc((0, 142.5), width=120, height=120, theta1=0, theta2=180, linewidth=lw, color=color, fill=False)

        # Free Throw Bottom Half Arc
        bottom_free_throw = Arc((0, 142.5), 120, 120, theta1=180, theta2=0, linewidth=lw, linestyle='--', color=color)

        # Restricted Zone
        restricted = Arc((0, 0), height=80, width=80, theta1=0, theta2=180, linewidth=lw, color=color)

        # Three Point Line
        corner_three_left = Rectangle((-220, -47.5), height=140, width=0, linewidth=lw, color=color)
        corner_three_right = Rectangle((220, -47.5), height=140, width=0, linewidth=lw, color=color)
        three_arc = Arc((0, 0), height=475, width=475, theta1=22, theta2=158, linewidth=lw, color=color)

        # Center Court
        center_outer_arc = Arc((0, 422.5), height=120, width=120, theta1=180, theta2=0, linewidth=lw, color=color)
        center_inner_arc = Arc((0, 422.5), height=40, width=40, theta1=180, theta2=0, linewidth=lw, color=color)

        court_elements = [hoop, rectangle, outer_box, inner_box, top_free_throw, bottom_free_throw, restricted, corner_three_left, corner_three_right, three_arc, center_outer_arc, center_inner_arc]
    

        if outer_lines:
            # Draw the half court line, baseline and side out bound lines
            outer_lines = Rectangle((-250, -47.5), height=500, width=470, linewidth=lw, color=color, fill=False)
            court_elements.append(outer_lines)
             

        for element in court_elements:
            ax.add_patch(element)

        return ax


# Drawing court with shot chart details

def shot_chart(player_data, title="", color="orange", xlim=(-250,250), ylim=(422.5,-47.5), line_color="orange",
               court_color="white", court_lw=2, outer_lines=False, flip_court=False, gridsize=None, ax = None):
     
    if ax is None:
        ax = plt.gca()

    if flip_court == False:
        ax.set_xlim(xlim)
        ax.set_ylim(ylim)
    else:
        ax.set_xlim(xlim[::-1])
        ax.set_ylim(ylim[::-1])

    ax.tick_params(labelbottom="off", labelleft="off")
    ax.set_title(title, fontsize=18)

    draw_court(ax, color=line_color, lw=court_lw, outer_lines=outer_lines)

    # defining made and missed shots
    x_missed = player_data[player_data['EVENT_TYPE'] == 'Missed Shot']['LOC_X']
    y_missed = player_data[player_data['EVENT_TYPE'] == 'Missed Shot']['LOC_Y']

    x_made = player_data[player_data['EVENT_TYPE'] == 'Made Shot']['LOC_X']
    y_made = player_data[player_data['EVENT_TYPE'] == 'Made Shot']['LOC_Y']

    # Plot missed shots
    ax.scatter(x_missed, y_missed, c='r', marker="x", s=300, linewidths=3)
    # Plot made shots
    ax.scatter(x_made, y_made, facecolors='none', edgecolors='g', marker='o', s=100, linewidths=3)

    return ax
        

player_name = 'Stephen Curry'
season_id = '2015-16'

# title
title = player_name + " Shot Chart " + season_id

# Get Shotchart Data using nba_api
player_shotchart_df, league_avg = player_shotchartdetail(player_name, season_id)

# Draw Court and plot Shot Chart
shot_chart(player_shotchart_df, title=title)
# Set the size for our plots
plt.rcParams['figure.figsize'] = (12, 11)
plt.show()



