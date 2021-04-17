function [dtrp,dtdx,var] = trop_model_prec(time, pos,azel,x)
%UNTITLED11 此处显示有关此函数的摘要
%   此处显示详细说明
    zazel = [0.0,pi/2.0];
%     double zhd,m_h,m_w,cotz,grad_n,grad_e;
    
%     /* zenith hydrostatic delay */
    zhd=tropmodel(time,pos,zazel,0.0);
    
%     /* mapping function */
    [m_h, m_w]=tropmapf(time,pos,azel,mapfw);

    if azel(2) > 0.0
        
%         /* m_w=m_0+m_0*cot(el)*(Gn*cos(az)+Ge*sin(az)): ref [6] */
        cotz=1.0/tan(azel(2));
        grad_n=m_w*cotz*cos(azel(1));
        grad_e=m_w*cotz*sin(azel(1));
        m_w = m_w + grad_n*x(2)+grad_e*x(3);
        dtdx(2)=grad_n*(x(1)-zhd);
        dtdx(3)=grad_e*(x(1)-zhd);
    end
    dtdx(1)=m_w;
    var=SQR(0.01);
    dtrp = m_h*zhd+m_w*(x(1)-zhd);


end

