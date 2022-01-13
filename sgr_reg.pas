unit sgr_reg;
{(c) S.P.Pod'yachev 1998-2001}
{
}
interface

uses Classes, sgr_def, sgr_data, sgr_eds, sgr_mark;

procedure Register;

implementation

procedure Register;
begin
 RegisterComponents('Sgraph', [Tsp_XYPlot,
                                Tsp_XYLine, Tsp_SpectrLines, Tsp_ndsXYLine, 
                                Tsp_LineMarker, Tsp_ImageMarker]);
 RegisterNonActiveX([Tsp_XYPlot, Tsp_XYLine, Tsp_SpectrLines, Tsp_ndsXYLine,
                                Tsp_LineMarker, Tsp_ImageMarker],
                                axrIncludeDescendants);
end;

end.
