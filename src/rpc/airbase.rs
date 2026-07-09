use stubs::airbase::v0::airbase_service_server::AirbaseService;
use stubs::*;
use tonic::{Request, Response, Status};

use super::MissionRpc;

#[tonic::async_trait]
impl AirbaseService for MissionRpc {
    async fn force_captures(
        &self,
        request: Request<airbase::v0::ForceCapturesResquest>,
    ) -> Result<Response<airbase::v0::ForceCapturesResponse>, Status> {
        let res = self.request("forceCaptures", request).await?;
        Ok(Response::new(res))
    }

    async fn force_capture(
        &self,
        request: Request<airbase::v0::CaptureInfos>,
    ) -> Result<Response<airbase::v0::ForceCaptureResponse>, Status> {
        let res = self.request("forceCapture", request).await?;
        Ok(Response::new(res))
    }
}
